# -*- coding: utf-8 -*
$: << File.join(File.dirname(__FILE__))
require 'test_helper'

class TestTable < MiniTest::Unit::TestCase 
  
  def test_one_table
    to = TableOutput.new([:id, :pero, :zdero], [[1, 'abc', 123], [10, 'defg', 'nesto']])
    output = "
+----+------+-------+
| id | pero | zdero |
+----+------+-------+
| 1  | abc  | 123   |
| 10 | defg | nesto |
+----+------+-------+
2 rows affected
"
    assert_equal output, to.to_s
  end

  def test_mb_chars
    assert_equal 20, "Sv.Martin pod Okicom".length
    assert_equal 20, "SV.martin pod Okićžš".scan(/./mu).size
  end

end
