# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cloud/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Michal Cichra"]
  gem.email         = ["michal@o2h.cz"]
  gem.description   = %q{command line app to create new EC2 instances}
  gem.summary       = gem.description
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "cloud"
  gem.require_paths = ["lib"]
  gem.version       = Cloud::VERSION
  
  gem.add_dependency "fog"
  gem.add_dependency "thor"
  
  gem.add_development_dependency "rspec"
end
