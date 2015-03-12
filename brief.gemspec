# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brief/version'

Gem::Specification.new do |spec|
  spec.name          = "brief"
  spec.version       = Brief::VERSION
  spec.authors       = ["Jonathan Soeder"]
  spec.email         = ["jonathan.soeder@gmail.com"]
  spec.summary       = %q{Brief makes writing more powerful}
  spec.description   = %q{Brief is a library for developing applications whose primary interface is the text editor}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'hashie'
  spec.add_dependency 'commander', '>= 4.2.1'
  spec.add_dependency 'github-fs'
  spec.add_dependency 'virtus', '>= 1.0.3'
  spec.add_dependency 'inflecto'
  spec.add_dependency 'activemodel'
  spec.add_dependency 'activesupport', '>= 4.0'
  spec.add_dependency 'redcarpet', '>= 3.2.2'
  spec.add_dependency 'nokogiri'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"

end


