require "marte-ruby/version"
require 'hmac-sha1'


module Marte
  module Ruby
    
    require 'lib/marte-ruby/railtie' if defined?(Rails)
    
    self.site = "http://marte.dit.upm.es:5080/marte/service"
    self.element_name = "token"
  
    KEY="secret"
    SERVICE_NAME="marteRed5"
    MAUTH_VERSION="3.1"
    MARTE_URL="marte.dit.upm.es"
    SWF_FILE = "http://marte.dit.upm.es/system/MartEClient.swf"
  
  
    #new is called MarteToken.new(:user=>'pepe', :role=>'admin', {:room_id=>'room_name'
    #save is called MarteToken.save
    #create is called MarteToken.create(:user=>'pepe', :role=>'admin', {:room_id=>'room
    #delete is called MarteToken.delete(id)
    #show is called MarteToken.find(:all)
  
    #define the headers to add Authentication
    def self.headers(user, attributes = {})
      #get the params to fill in the headers
      role = 'admin'
  
      #timestamp without decimals
      timestamp=Time.now.to_i
  
      #cnonce, we use a randon number between 1 and 999.999.999
      cnonce=rand(1000000000)
  
      #now we prepare the signature. It is a HMAC:SHA1 of "timestamp,cnonce,username,ro
      to_sign="#{timestamp},#{cnonce},#{user.name},#{role},#{ user.id }"
      extra_header=",mauth_username=\"#{user.name}\",mauth_role=\"#{role}\",mauth_external_uid\=#{ user.id }"
  
      #puts "cosas pa firmar " + to_sign
      signature=Base64.encode64(HMAC::SHA1.hexdigest(KEY, to_sign)).chomp.gsub(/\n/,'')
  
      #everything ready, create the message headers
      headers = {
        "Accept" => "application/html",
        "Content-Type" => "application/html",
        "Authorization"=> "MAuth realm=\"#{MARTE_URL}\", mauth_signature_method=\"HMAC_SHA1\", mauth_serviceid=\"#{SERVICE_NAME}\",mauth_signature=\"#{signature}\",mauth_timestamp=\"#{timestamp}\",mauth_cnonce=\"#{cnonce}\",mauth_version=\"#{MAUTH_VERSION}\"#{extra_header}"
      }
    end
  
    #redefined to remove format.extension
    def self.collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
  
    def self.element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
    end
  
    def createToken(user, room)
      connection.post(collection_path, room, self.class.headers(user, attributes)) do |response|
        self.id = id_from_response(response)
        load_attributes_from_response(response)
      end
    end
  
    def embed_for(user, room, mobile = false, width_value=750, height_value=600)
      token = createToken(user, room).body
  
      if mobile
  <<-EMBED
  marte://params/#{token}/#{room}/#FFFFFF
  EMBED
      else
  <<-EMBED
  <object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" id=\"MartEClient\" width=\"#{width_value}\" height=\"#{height_value}\" codebase=\"http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab\">
                                  <param name=\"movie\" value=\" #{ SWF_FILE }\" />
                                  <param name=\"quality\" value=\"high\" />
                                  <param name=\"allowScriptAccess\" value=\"sameDomain\" />
                                  <param name=\"allowFullscreen\" value=\"true\" />
                                  <param name=\"flashVars\" value=\"token=#{token}&room=#{room}&bgcolor=#FFFFFF\" />
                                  <embed src=\"#{ SWF_FILE }\" quality=\"high\" \"
                                          width=\"#{width_value}\" height=\"#{height_value}\" name=\"MartEClient\" align=\"top\" padding=\"0px 0px 0px 0px\"
                                          flashVars=\"token=#{token}&room=#{room}&bgcolor=#FFFFFF\"
                                          play=\"true\"
                                          loop=\"false\"
                                          quality=\"high\"
                                          allowScriptAccess=\"sameDomain\"
                                          allowFullscreen=\"true\"
                                          type=\"application/x-shockwave-flash\"
                                          pluginspage=\"http://www.adobe.com/go/getflashplayer\">
                                  </embed>
                            </object>
  EMBED
      end
    end
  end
end






