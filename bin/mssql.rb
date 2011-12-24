#!/usr/bin/env ruby
require 'pathname'
$: << File.join(File.dirname(Pathname.new(__FILE__).realpath), "..")
require 'lib/mssql'

## dumiest redline ever
# print "> "
# $stdin.each_line do |line|
#   print line
#   print "> "
# end
# exit

controller = Controller.new
controller.run
