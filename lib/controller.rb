require 'readline'

class Controller
  
  def initialize(options)
    @connection = Connection.new options
    @prompt = "#{options.username}@#{options.host}> "
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
          exec lines.join("\n")
          break
        end
        lines << line
      end
    end
  end

  private

  def exec(sql)
    @connection.show sql 
  end
  
end
