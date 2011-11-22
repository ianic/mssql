class QueryExec
  
  def initialize(options)
    @client = TinyTds::Client.new(
                                  :username => options.username,
                                  :password => options.password,
                                  :host => options.host,
                                  :database => options.database
                                  )
    @prompt = "#{options.username}@#{options.host}"
  end
  
  def stdin_loop
    prompt
    while (line = STDIN.gets) do
      result = parse_cmd line
      print_tables result
      prompt
    end
  end

  def parse_cmd(line)
    exit(0) if line.strip == 'exit'
    exec line
  end

  def prompt
    print "#{@prompt}>"
  end
  
  def print_tables(result)
    if result.columns.first.kind_of?(Array)
      (0..result.columns.size-1).each do |index|
        print TableOutput.new(result.columns[index], result.rows[index]).to_s
      end
    else
      print TableOutput.new(result.columns, result.rows).to_s
    end
  end

  def exec(sql)
    begin
      result = @client.execute sql
      rows = result.each(:symbolize_keys => true, :empty_sets => true, :as => :array)
      Hashie::Mash.new({:columns => result.fields, :rows => rows, :affected => result.do, :return_code => @client.return_code})
    rescue TinyTds::Error => e
      Hashie::Mash.new(:error => e.to_s, :severity => e.severity, :db_error_number => e.db_error_number)
    end
  end
  
end
