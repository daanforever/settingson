# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'settingson/version'

Gem::Specification.new do |spec|
  spec.name          = "settingson"
  spec.version       = Settingson::VERSION
  spec.authors       = ["dan"]
  spec.email         = ["daan.forever@gmail.com"]
  spec.summary       = %q{Settings management for Ruby on Rails 4 applications (ActiveRecord) }
  spec.description   = %q{Settings management for Ruby on Rails 4 applications (ActiveRecord) }
  spec.homepage      = "https://github.com/daanforever/settingson"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "app/models/concerns"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
