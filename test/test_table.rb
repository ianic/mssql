require 'test_helper'

class TestTable < Test::Unit::TestCase 
  
  def setup         
    @result1 = Hashie::Mash.new({:columns => [:id, :pero, :zdero], :rows => [[1,2,3], [4,5,6], [7,8,10]]})
  end                      
  
  def test_one_table
    to = TableOutput.new([:id, :pero, :zdero], [{:id =>1, :pero=>'abc', :zdero=>123}, {:id=>10, :pero=>'defg', :zdero=>'nesto'}])
    output = "|  id| pero|zdero|
| abc|  123|    1|
|defg|nesto|   10|"
    assert_equal output, to.to_s
  end

end
