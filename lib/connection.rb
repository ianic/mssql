class Connection
  
  def initialize(options)
    @client = TinyTds::Client.new(
                                  :username => options.username,
                                  :password => options.password,
                                  :host => options.host,
                                  :database => options.database
                                  )
  end
  
  attr_reader :results, :error

  def error?
    !@error.nil?
  end

  def one_column_one_row?
    return false if error?
    @results.rows.size == 1 && @results.columns.size == 1
  rescue
    false
  end

  def exec(sql)
    begin
      result = @client.execute sql
      rows = result.each(:symbolize_keys => true, :empty_sets => true, :as => :array)
      @results = Hashie::Mash.new({
                                    :columns => result.fields, 
                                    :rows => rows, 
                                    :affected => result.do, 
                                    :return_code => @client.return_code
                                  })
      @error = nil
      @results
    rescue TinyTds::Error => e
      @result = nil
      @error = Hashie::Mash.new(:error => e.to_s, :severity => e.severity, :db_error_number => e.db_error_number)
    end
  end
  
end
