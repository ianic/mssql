require 'readline'

class Controller
  
  def initialize
    read_configs
    @connection = Connection.new @configs
    @prompt = "#{@connection.name}> "
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
    stty_save = `stty -g`.chomp
    trap('INT') do
      system('stty', stty_save); 
      exit       
    end
  end

  def show(query)
    QueryOutput.new(@connection, query).show
  end

  def read_configs
    file_configs = YAML.load_file "#{ENV['HOME']}/.mssql" rescue {}
    @configs = Hashie::Mash.new(file_configs)
    params = ParamsParser.new
    unless params.options.empty?
      @configs.default_connection = params
    end
    unless @configs.default_connection
      params.print_usage
      exit
    end
  end
  
end
