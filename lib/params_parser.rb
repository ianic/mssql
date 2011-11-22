class ParamsParser

  def initialize
    @options = Hashie::Mash.new
    parse
  end

  def parse
    @opts = OptionParser.new do |opts|
      opts.banner = ""
      available_options = [ 
                           ['-S', 'host',     'server host'],
                           ['-U', 'username', 'username'],
                           ['-P', 'password', 'password'],
                           ['-d', 'database', 'use database name'],
                           ['-w', 'columnwidth', 'column width']
                          ]
      available_options.each do |o|
        opts.on(o[0], "--#{o[1]} #{o[1].upcase}", o[2]) do |value|
          @options[o[1]] = value
        end
      end
      opts.on("-n", "--no-numbering", "remove numbering") do
        
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

  attr_reader :options
end
