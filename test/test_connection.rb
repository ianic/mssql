require 'test_helper'

class TestConnection < Test::Unit::TestCase 
  
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

    options = Hashie::Mash.new({:default_connection => { :username => 'sa', :password => 'dsalkjmn', :host => 'iow', :database => "pubs"}})
    @query_exec = Connection.new(options)
  end                      
  
  def test_simple_select
    result = @query_exec.exec "select * from authors"

    assert_equal 23, result.rows.size 
    assert_equal 9, result.columns.size
    assert_equal @authors_columns, result.columns
    assert_equal @authors_first_row, result.rows.first
    assert_equal 23, result.affected
  end

  def test_two_results
    result = @query_exec.exec "select * from authors order by au_id; select * from employee"

    assert_equal 2, result.columns.size
    assert_equal 2, result.rows.size
    assert_equal @authors_columns, result.columns[0]
    assert_equal @authors_first_row, result.rows[0].first
  end

  def test_no_results
    result = @query_exec.exec "update authors set phone = phone where au_id in ('172-32-1176', '213-46-8915', '238-95-7766')"
    assert_equal 3, result.affected
  end

  def test_results_and_no_results
    result = @query_exec.exec "select * from authors; 
                   update authors set phone = phone where au_id in ('172-32-1176', '213-46-8915', '238-95-7766'); 
                   select * from employee"

    assert_equal 2, result.columns.size
    assert_equal 2, result.rows.size
    assert_equal @authors_columns, result.columns[0]
    assert_equal @authors_first_row, result.rows[0].first
    assert_equal 43, result.affected
  end


  def test_error
    result = @query_exec.exec "select * from pero"
    assert_equal "Invalid object name 'pero'.", result.error
  end

  def test_update_and_error
    result = @query_exec.exec "update authors set phone = phone where au_id in ('172-32-1176', '213-46-8915', '238-95-7766'); select * from pero;"
    assert_equal "Invalid object name 'pero'.", result.error
  end

end
