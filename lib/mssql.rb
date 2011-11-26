require 'optparse'

require 'rubygems'
require "bundler/setup" 
require 'tiny_tds'
require 'hashie'

$: << File.join(File.dirname(__FILE__))

require 'params_parser'
require 'connection'
require 'table_output'
require 'command'
require 'controller'
require 'query_output'
