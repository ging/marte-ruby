# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "marte-ruby/version"

Gem::Specification.new do |s|
  s.name        = "marte-ruby"
  s.version     = Marte::Ruby::VERSION
  s.authors     = ["Aldo Gordillo"]
  s.email       = ["iamchrono@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "marte-ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  
  # Gem dependencies
  s.add_development_dependency "rspec", "2.1.0"
  s.add_dependency "rails", "3.0.1"
  s.add_dependency('activeresource', '~> 3.0.1')
  
end

