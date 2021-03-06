class ParamsParser

  def initialize    
    @options = Hashie::Mash.new
    parse
  end

  def parse
    @opts = OptionParser.new do |opts|
      opts.banner = ""
      available_options = [ 
                           ['-c', 'connection', 'use connection defined in ~/.mssql'],
                           ['-h', 'host',       'server host'],
                           ['-u', 'username',   'username'],
                           ['-p', 'password',   'password'],
                           ['-d', 'database',   'use database name'],
                           ['-i', 'input_file', 'input file name'],
                           ['-q', 'query',      'run query and exit']
                          ]
      available_options.each do |o|
        opts.on(o[0], "--#{o[1]} #{o[1].upcase}", o[2]) do |value|
          @options[o[1]] = value
        end
      end
      opts.on_tail("-?", "--help", "show syntax summary") do
        print_usage
        exit
      end
    end
    @opts
    @opts.parse!(ARGV)
    @opts
  end

  def print_usage
    puts <<-END
  Usage: #{File.basename($0)} <options>
  #{@opts.to_s}
END
  end

  def missing_key(keys)
    keys.find do |key|
      !@options.has_key?(key.to_s)      
    end
  end

  attr_reader :options
end
