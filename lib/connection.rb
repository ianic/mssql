class Connection
  
  def initialize(configs)
    @configs = configs
    @current_config = @configs.default_connection
    connect
  end
  
  attr_reader :results, :error, :name

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

  private
  
  def connect
    @client = TinyTds::Client.new(
                                  :username => @current_config.username,
                                  :password => @current_config.password,
                                  :host =>     @current_config.host,
                                  :database => @current_config.database
                                  )
    @name = "#{@current_config.username}@#{@current_config.host}"   
  end
  
end
