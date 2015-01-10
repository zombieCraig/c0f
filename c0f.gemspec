# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'c0f/version'

Gem::Specification.new do |spec|
  spec.name          = "c0f"
  spec.version       = C0f::VERSION
  spec.authors       = ["Craig Smith"]
  spec.email         = ["craig@theialabs.com"]
  spec.summary       = %q{c0f - CAN Bus Fingerprinting}
  spec.description   = %q{c0f - CAN of Fingers.  CAN Bus fingerprinting to passively determine make/model of vehicle}
  spec.homepage      = "http://opengarages.orb"
  spec.license       = "GPLv3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 4.7"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('aruba')
  spec.add_dependency('methadone', '~> 1.8')
  spec.add_dependency('formatador')
  spec.add_dependency('sqlite3')
  spec.add_dependency('json')
end
