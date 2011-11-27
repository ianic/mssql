require 'readline'

class Controller
  
  def initialize
    connect
    # @prompt = "#{@connection.name}> "
    trap_int
  end

  def run
    loop do
      lines = []
      while line = Readline.readline(@prompt, true)
        next if line.empty?
        if lines.empty?
          command = Command.new(line, @connection)
          return if command.exit?
          break  if command.processed?
        end 
        if Command.go?(line)
          show lines.join("\n")
          break
        end
        lines << line
      end                  
      if $stdin.eof?
        show lines.join("\n")
        return
      end
    end
  end

  private

  def trap_int
    #stty_save = `stty -g`.chomp
    trap('INT') do
      #system('stty', stty_save); 
      exit       
    end
  end

  def show(query)
    QueryOutput.new(@connection, query).show
  end

  def connect
    read_configs
    @connection = Connection.new @configs, Proc.new{ |name| @prompt = "#{name}> " }
  rescue TinyTds::Error => e
    print "#{e.to_s}\n"
    exit
  end

  def read_configs
    file_configs = YAML.load_file "#{ENV['HOME']}/.mssql" rescue {}
    @configs = Hashie::Mash.new(file_configs)
    params = ParamsParser.new
    unless params.options.empty?      
      if params.options.connection
        key = params.options.connection.to_s
        if @configs.has_key?(key)
          @configs.default_connection = @configs[key]
        else
          print "unkonwn connection #{key}\n"
          exit 1
        end
      else
        if missing = params.missing_key(Connection::KEYS)
          print "missing #{missing} param\n"
          exit 2
        end
        @configs.default_connection = params.options 
      end
    end
    unless @configs.default_connection
      params.print_usage
      exit 3
    end
  end
  
end
