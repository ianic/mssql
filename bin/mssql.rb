#!/usr/bin/env ruby
$: << File.join(File.dirname(__FILE__), "..")
require 'lib/mssql'
require 'pp'

params = ParamsParser.new
exec = QueryExec.new params.options
exec.stdin_loop
