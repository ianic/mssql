#!/usr/bin/env ruby
require 'pathname'
$: << File.join(File.dirname(Pathname.new(__FILE__).realpath), "..")
require 'lib/mssql'

params = ParamsParser.new
controller = Controller.new params.options
controller.run
