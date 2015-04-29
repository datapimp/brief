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
  spec.homepage      = "https://architects.io/brief"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'hashie', '~> 2.0', '< 3.0'
  spec.add_dependency 'commander', '~> 4.3'
  spec.add_dependency 'github-fs', '~> 0'
  spec.add_dependency 'virtus', '~> 1.0'
  spec.add_dependency 'inflecto', '~> 0'
  spec.add_dependency 'activesupport', '~> 4.0'
  spec.add_dependency 'hike', '~> 2.1'
  spec.add_dependency 'nokogiri', '1.6.5'

  #spec.add_dependency 'github-markup',       '~> 1.3.1'
  #spec.add_dependency 'github-linguist',     '~> 4.2.5'
  #spec.add_dependency 'html-pipeline',       '~> 1.11.0'
  #spec.add_dependency 'sanitize',            '~> 3.1.0'
  spec.add_dependency 'github-markdown',     '0.6.8'
  spec.add_dependency 'eventmachine', '1.0.6'
  spec.add_dependency 'em-websocket', '0.5.1'
  spec.add_dependency 'thin', '1.6.3'
  spec.add_dependency 'dnode'
 

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency 'octokit', "~> 3.0"
end


