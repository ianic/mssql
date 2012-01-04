# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Igor Anic"]
  gem.email         = ["ianic@minus5.hr"]
  gem.description   = "mssql server command line tool"
  gem.summary       = "mssql server command line  tool"
  gem.homepage      = "http://www.minus5.hr"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  #gem.executables   = "mssql"
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "mssql"
  gem.require_paths = ["lib", "bin"]
  gem.version       = Mssql::VERSION

  gem.add_dependency('tiny_tds'         , '~> 0.5.0')
  gem.add_dependency('hashie'           , '~> 1.0.0')
  #gem.add_dependency('multi_json'       , '~> 1.0.3')
  gem.add_dependency('activesupport'    , '~> 3.1.1')
  # gem.add_dependency('ZenTest'          , '~> 4.6.2')
  # gem.add_dependency('minitest'         , '~> 2.7.0')
  # gem.add_dependency('autotest-fsevent' , '~> 0.2.5')
  # gem.add_dependency('autotest-growl'   , '~> 0.2.14')
end
