# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "marte/version"

Gem::Specification.new do |s|
  s.name        = "marte-ruby"
  s.version     = Marte::VERSION
  s.authors     = ["GING - UPM"]
  s.email       = ["social-stream@dit.upm.es"]
  s.homepage    = "https://github.com/ging/marte-ruby"
  s.summary     = "Gem summary"
  s.description = "Gem description"

  s.rubyforge_project = "marte-ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  
  # Gem dependencies
  s.add_development_dependency "rspec", "> 2.1.0"
  s.add_dependency "rails", "> 3.0.1"
  s.add_dependency('activeresource', '> 3.0.1')
  
end

