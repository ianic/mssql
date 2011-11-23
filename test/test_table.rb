require 'test_helper'

class TestTable < Test::Unit::TestCase 
  
  def setup         
    @result1 = Hashie::Mash.new({:columns => [:id, :pero, :zdero], :rows => [[1,2,3], [4,5,6], [7,8,10]]})
  end                      
  
  def test_one_table
    to = TableOutput.new([:id, :pero, :zdero], [[1, 'abc', 123], [10, 'defg', 'nesto']])
    output = "+--+----+-----+
|id|pero|zdero|
+--+----+-----+
| 1| abc|  123|
|10|defg|nesto|
+--+----+-----+
"
    assert_equal output, to.to_s
  end

end
