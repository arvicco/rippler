# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rippler/version'

Gem::Specification.new do |gem|
  gem.name          = "rippler"
  gem.version       = Rippler::VERSION
  gem.authors       = ["arvicco"]
  gem.email         = ["arvicco@gmail.com"]
  gem.description   = %q{Command line client for Ripple payment platform}
  gem.summary       = %q{Command line client for Ripple payment platform, uses websocket API}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'faye-websocket', '~> 0.4'
  # gem.add_dependency 'websocket-eventmachine-client', '~> 1.0'
end
