require 'hmac-sha1'


module Marte
  class Token < ActiveResource::Base
  
    self.site = "http://marte4.dit.upm.es:5080/vaas/service"
    self.element_name = "token"
  
    KEY="secret"
    SERVICE_NAME="marteRed5"
    MAUTH_VERSION="3.1"
    MARTE_URL="marte.dit.upm.es"
    ROOM_SWF_FILE = "http://marte.dit.upm.es/system/MartEClient.swf"
    CHAT_SWF_FILE = "http://marte.dit.upm.es/system/MartEClient.swf"
  
    #define the headers to add Authentication
    def self.headers(user, attributes = {})
      #get the params to fill in the headers
      role = 'admin'
  
      #timestamp without decimals
      timestamp=Time.now.to_i
  
      #cnonce, we use a randon number between 1 and 999.999.999
      cnonce=rand(1000000000)
  
      #now we prepare the signature. It is a HMAC:SHA1 of "timestamp,cnonce,username,ro
      to_sign="#{timestamp},#{cnonce},#{user.slug},#{role},#{ user.id }"
      extra_header=",mauth_username=\"#{user.slug}\",mauth_role=\"#{role}\",mauth_external_uid\=#{ user.id }"
  
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

    def self.embed_for(*args)
      new.embed_for(*args)
    rescue StandardError => e
      "The following error ocurred with the conference server: #{ e }"
    end
  
    def createToken(user, room)
      connection.post(collection_path, room, self.class.headers(user, attributes)) do |response|
        self.id = id_from_response(response)
        load_attributes_from_response(response)
      end
    end
  
    def embed_for(user, room, options = {})
      options[:width]  ||= 750
      options[:height] ||= 600
      swf_file = ( options[:partner].present? ? ROOM_SWF_FILE : CHAT_SWF_FILE )

      token = createToken(user, room).body
  
      <<-EMBED
  <object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" id=\"MartEClient\" width=\"#{ options[:width] }\" height=\"#{ options[:height] }\" codebase=\"http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab\">
                                  <param name=\"movie\" value=\" #{ swf_file }\" />
                                  <param name=\"quality\" value=\"high\" />
                                  <param name=\"allowScriptAccess\" value=\"sameDomain\" />
                                  <param name=\"allowFullscreen\" value=\"true\" />
                                  <param name=\"flashVars\" value=\"token=#{token}&room=#{room}&bgcolor=#FFFFFF\" />
                                  <embed src=\"#{ swf_file }\" quality=\"high\" \"
                                          width=\"#{options[:width]}\" height=\"#{options[:height]}\" name=\"MartEClient\" align=\"top\" padding=\"0px 0px 0px 0px\"
                                          flashVars=\"token=#{token}&room=#{room}&bgcolor=#FFFFFF#{ "&partner=#{ options[:partner].slug }" if options[:partner] }\"
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
