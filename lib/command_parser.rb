class CommandParser

  def initialize(line)
    @line = line
    @command = nil
    @params = nil
    parse
  end

  attr_reader :command, :params

  def is_command?
    !@command.nil?
  end

  def parse
    m = @line.match /^\s*\.(\w+) *(.*)$/
    return if m.nil?
    @command = m[1].to_sym
    @params = m[2].split(' ').compact.map{|p| p.split(".")}.flatten
    case @command
      when "find"
      when "explain"
      when "use"
    end
  end
 
end
