require 'test/unit'
require 'minitest/unit'
require 'pp'   

$: << File.join(File.dirname(__FILE__), "../lib")
require 'mssql'

class MiniTest::Unit::TestCase                                         
  
  def load_fixture(file_name)
    YAML.load(File.open("test/fixtures/#{file_name}.yml")) 
  end  
  
  def assert_string(value)
    assert_not_nil value
    assert value.kind_of?(String)
  end                            
  
  def assert_int(value)
    assert_not_nil value
    assert value.kind_of?(Fixnum)
  end                           
  
  def assert_time(value)
    assert_not_nil value
    assert value.kind_of?(Time)
  end  
  
  def assert_in_range(range, value)
    assert range.include?(value.to_i)    
  end    
  
  def assert_time(expected, actual, message = nil)
    assert_equal expected, actual.strftime("%Y-%m-%d %H:%M"), message    
  end

  def assert_same_hash(expected, actual)
    compare_hashes expected, actual
    compare_hashes actual, expected
  end

  def compare_hashes(h1, h2)
    h1.each_pair do |key, value|
      assert_equal value, (h2[key.to_sym] || h2[key.to_s])
    end    
  end
  
end
