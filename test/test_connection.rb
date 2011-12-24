require 'test_helper'

class TestConnection < MiniTest::Unit::TestCase 
  
  def setup         
    @authors_first_row = ["172-32-1176",
                          "White",
                          "Johnson",
                          "408 496-7223",
                          "10932 Bigge Rd.",
                          "Menlo Park",
                          "CA",
                          "94025",
                          true]
    @authors_columns = [:au_id,
                        :au_lname,
                        :au_fname,
                        :phone,
                        :address,
                        :city,
                        :state,
                        :zip,
                        :contract]

    conn1 = { 
      :username => 'ianic', 
      :password => 'ianic', 
      :host => 'iow', 
      :database => "pubs"}
    conn2 = { 
      :name => 'conn2_name',
      :username => 'ianic2', 
      :password => 'ianic2', 
      :host => 'iow', 
      :database => "pubs"}
    options = Hashie::Mash.new({:default_connection => conn1, :conn1 => conn1, :conn2 => conn2})
    @name = ''
    @connection = Connection.new options, Proc.new {|name| @name = name}
  end                      
  
  def test_simple_select
    result = @connection.exec "select * from authors"

    assert_equal 23, result.rows.size 
    assert_equal 9, result.columns.size
    assert_equal @authors_columns, result.columns
    assert_equal @authors_first_row, result.rows.first
    assert_equal 23, result.affected
  end

  def test_two_results
    result = @connection.exec "select * from authors order by au_id; select * from employee"

    assert_equal 2, result.columns.size
    assert_equal 2, result.rows.size
    assert_equal @authors_columns, result.columns[0]
    assert_equal @authors_first_row, result.rows[0].first
  end

  def test_no_results
    result = @connection.exec "update authors set phone = phone where au_id in ('172-32-1176', '213-46-8915', '238-95-7766')"
    assert_equal 3, result.affected
  end

  def test_results_and_no_results
    result = @connection.exec "select * from authors; 
                   update authors set phone = phone where au_id in ('172-32-1176', '213-46-8915', '238-95-7766'); 
                   select * from employee"

    assert_equal 2, result.columns.size
    assert_equal 2, result.rows.size
    assert_equal @authors_columns, result.columns[0]
    assert_equal @authors_first_row, result.rows[0].first
    assert_equal 43, result.affected
  end

  def test_error
    result = @connection.exec "select * from pero"
    assert_equal "Invalid object name 'pero'.", result.error
  end

  def test_update_and_error
    result = @connection.exec "update authors set phone = phone where au_id in ('172-32-1176', '213-46-8915', '238-95-7766'); select * from pero;"
    assert_equal "Invalid object name 'pero'.", result.error
  end

  def test_change_connection
    assert @connection.use :conn2
    assert_equal 23, @connection.exec("select * from authors").rows.size
    assert @connection.use :conn1
    assert_equal 23, @connection.exec("select * from authors").rows.size
    assert_equal "ianic@iow", @connection.name
    
    assert !@connection.use(:unknown)
  end

  def test_connection_name
    assert_equal 'ianic@iow', @name
    assert @connection.use :conn2
    assert_equal 'conn2_name', @name
  end

end
