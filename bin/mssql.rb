#!/usr/bin/env ruby
require 'pathname'
$: << File.join(File.dirname(Pathname.new(__FILE__).realpath), "..")
require 'lib/mssql'

controller = Controller.new
controller.run
