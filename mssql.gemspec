# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Igor Anic"]
  gem.email         = ["ianic@minus5.hr"]
  gem.description   = "mssql server command line tool"
  gem.summary       = "Command line tool for connecting to Microsoft Sql Server from Mac or Linux."
  gem.homepage      = "http://www.minus5.hr"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "mssql"
  gem.require_paths = ["lib"]
  gem.version       = Mssql::VERSION

  gem.add_dependency('tiny_tds'         , '~> 0.5.0')
  gem.add_dependency('hashie'           , '~> 1.0.0')
  gem.add_dependency('activesupport'    , '~> 3.1.1')
end
