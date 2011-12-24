$: << File.join(File.dirname(__FILE__))
require 'test_helper'

class TestCommandParser < MiniTest::Unit::TestCase

  def test_find
    cp = CommandParser.new(' .find    nesto')
    assert_equal :find, cp.command
    assert_equal ["nesto"], cp.params
  end

  def test_explain
    cp = CommandParser.new(' .explain  dbo.authors')
    assert_equal :explain, cp.command
    assert_equal ["dbo", "authors"], cp.params
  end

  def test_use
    cp = CommandParser.new(' .use  connection2')
    assert_equal :use, cp.command
    assert_equal ["connection2"], cp.params
  end
    
  
end
