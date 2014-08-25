# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-epson/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-epson"
  spec.version       = Omniauth::Epson::VERSION
  spec.authors       = ["Bethany Marie Soule"]
  spec.email         = ["bsoule@gmail.com"]
  spec.description   = "OmniAuth strategy for Epson" 
  spec.summary       = "This is an omniauth strategy for epson" 
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
