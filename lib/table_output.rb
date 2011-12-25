class TableOutput

  def initialize(cols, rows)
    @cols = cols
    @rows = rows
    calc_sizes
    @ascii_encoding = Encoding.find("ASCII-8BIT")  
  end

  def calc_sizes
    @sizes = []
    @align = []
    @cols.each_with_index do |col, index|
      @sizes[index] = col.to_s.length
      @align[index] = '-'

    end
    @rows.each do |row|
      row.each_with_index do |value, index|        
        row[index] = value = format_value(value, index)
        size = value.length
        if @sizes[index] < size
          @sizes[index] = size
        end
      end
    end
  end

  #FIXME - hard coded formating for floats and times
  def format_value(value, index)
    if value.class == String && value.encoding.to_s == "ASCII-8BIT" #timestamps and binary data
      a =  value.unpack("C" * value.size)
      value = "%x"*a.size % a
    elsif value.class == Float || value.class == BigDecimal
      value = "%.4f" % [value]
      @align[index] = "+"
    elsif value.class == BigDecimal
      value = value.to_s('F')
      @align[index] = "+"
    elsif value.class == Fixnum 
      @align[index] = "+"
    elsif value.class == Time
      value = value.
        strftime("%F %T").
        gsub(" 00:00:00", "")
      @align[index] = "+"
    end    
    #print "#{@cols[index]}\t#{value.class}\t#{value.to_s}\n"
    value.to_s
  end

  def to_s
    format = @sizes.each_with_index.map{|s, i| " %#{@align[i]}#{s}s "}.join("|")
    output = []

    separator = @sizes.map{|s| "-" * (s+2)}.join("+")
    separator = "+#{separator}+"
    output << ""
    output << separator
    output << "|#{format}|" % @cols
    output << separator
    @rows.each do |row|
      output << "|#{format}|" % row
    end
    output << separator
    output << "#{@rows.size} rows affected"
    output << ""
    output.join("\n")
  end

end
