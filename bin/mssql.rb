#!/usr/bin/env ruby-local-exec
require 'pathname'
$: << File.join(File.dirname(Pathname.new(__FILE__).realpath), "..")
require 'lib/mssql'

controller = Controller.new
controller.run
