class QueryOutput

  def initialize(connection, query)
    @connection = connection
    @query = query
  end

  def show
    exec 
    @connection.error? ? print_error : print_tables
  end

  def show_text_or_table
    exec 
    if @connection.one_column_one_row?
      print_text
    else
      print_tables unless @connection.error?
    end
    print_error if @connection.error?
  end

  private

  def print_error
    error = @connection.error
    print "\nmsg: #{error.db_error_number}, severity: #{error.severity}\n#{error.error}\n" 
  end

  def print_text
    print @connection.results.rows[0][0]
    print "\n"
  rescue
  end
  
  def print_tables
    results = @connection.results
    if results.columns.first.kind_of?(Array)
      (0..results.columns.size-1).each do |index|
        print TableOutput.new(results.columns[index], results.rows[index]).to_s
      end
    else
      if results.columns.size > 0
        print TableOutput.new(results.columns, results.rows).to_s
      else
        print "#{results.affected} rows affected\n"
      end
    end
  end

  def exec
    @connection.exec @query
  end

end
