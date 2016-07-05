# -*- encoding: utf-8 -*-
require File.expand_path('../lib/affairs_of_state/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kevin McPhillips"]
  gem.email         = ["github@kevinmcphillips.ca"]
  gem.description   = %q{Add a simple state to a gem, without all the hassle of a complex state machine.}
  gem.summary       = %q{You have an Active Record model. It nees to have multiple states, but not complex rules. This gem gives you validation, easy check and change methods, and a single configuration line.}
  gem.homepage      = "http://github.com/kmcphillips/affairs_of_state"
  gem.license       = 'MIT'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "affairs_of_state"
  gem.require_paths = ["lib"]
  gem.version       = AffairsOfState::VERSION

  gem.add_dependency "activerecord", ">= 4.0"
  gem.add_dependency "activesupport", ">= 4.0"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "pry"

end
