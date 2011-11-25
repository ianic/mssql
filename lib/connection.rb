class Connection
  
  def initialize(options)
    @client = TinyTds::Client.new(
                                  :username => options.username,
                                  :password => options.password,
                                  :host => options.host,
                                  :database => options.database
                                  )
  end

  def show(sql)
    exec sql
    print_tables if @result
    print_error  if @error
  end

  def show_text_or_table(sql)
    exec sql
    if one_column_one_row?
      print_text
    else
      print_tables if @result
    end
    print_error  if @error
  end

  private

  def one_column_one_row?
    @result.rows.size == 1 && @result.columns.size == 1
  rescue
    false
  end

  def print_error
    print "\nmsg: #{@error.db_error_number}, severity: #{@error.severity}\n#{@error.error}\n" 
  end

  def print_text
    print @result.rows[0][0]
    print "\n"
  rescue
  end
  
  def print_tables
    if @result.columns.first.kind_of?(Array)
      (0..@result.columns.size-1).each do |index|
        print TableOutput.new(@result.columns[index], @result.rows[index]).to_s
      end
    else
      print TableOutput.new(@result.columns, @result.rows).to_s
    end
  end

  def exec(sql)
    @result = nil
    @error = nil
    begin
      result = @client.execute sql
      rows = result.each(:symbolize_keys => true, :empty_sets => true, :as => :array)
      @result = Hashie::Mash.new({:columns => result.fields, :rows => rows, :affected => result.do, :return_code => @client.return_code})
    rescue TinyTds::Error => e
      @error = Hashie::Mash.new(:error => e.to_s, :severity => e.severity, :db_error_number => e.db_error_number)
    end
  end
  
end
