require 'optparse'
require 'pp'

require 'rubygems'
require "bundler/setup" 
require 'tiny_tds'
require 'hashie'
require 'active_support/core_ext/hash/keys.rb'

$: << File.join(File.dirname(__FILE__))

require 'params_parser'
require 'connection'
require 'table_output'
require 'command'
require 'controller'
require 'query_output'
require 'command_parser'

STDOUT.sync = false#true
