require 'readline'

class Controller
  
  def initialize
    connect
    trap_int
    @lines = []
  end

  def run
    if ENV["EMACS"] == "t"
      emacs_run_loop
    elsif @options.input_file
      show File.read(@options.input_file)
    elsif @options.query
      show @options.query
    else
      run_loop
    end
  end

  private

  def emacs_run_loop    
    print @prompt
    $stdin.flush
    $stdin.each_line do |line|
      #print "emacs_run_loop #{line}"
      ret = handle_line(line)      
      print @prompt unless has_more?
      $stdout.fsync
      break if ret && ret < 0      
    end
  end

  def has_more?
    c = $stdin.read_nonblock(1) rescue nil
    $stdin.ungetbyte(c) if c
    !!c
  end

  def run_loop
    loop do
      while line = Readline.readline(@prompt, true)
        ret = handle_line(line)
        return if ret && ret < 0
      end
      exec_lines
    end
  end

  def handle_line(line)
    line = line.strip
    return if line.empty?
    command = Command.new(line, @connection)
    if command.exit?
      exec_lines
      return -1 
    end      
    if command.go?
      exec_lines
    end
    return 0 if command.exec
    @lines << line    
    # if $stdin.eof?
    #   exec_lines 
    #   return -1
    # end
    0
  end

  def exec_lines
    show @lines.join("\n")
    @lines = []
  end

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
    file_configs = YAML.load(File.read("#{ENV['HOME']}/.mssql")) rescue {}
    @configs = Hashie::Mash.new(file_configs)    
    params = ParamsParser.new
    @options = params.options
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
