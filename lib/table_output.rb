class TableOutput

  def initialize(cols, rows)
    @cols = cols
    @rows = rows
    calc_sizes
  end

  def calc_sizes
    @sizes = []
    @cols.each_with_index do |col, index|
      @sizes[index] = col.to_s.length
    end
    @rows.each do |row|
      data_row = []
      row.each_with_index do |value, index|
        size = value.to_s.length
        if @sizes[index] < size
          @sizes[index] = size
        end
      end
    end
  end

  def to_s
    format = @sizes.map{|s| "%-#{s}s"}.join("|")
    output = []

    separator = @sizes.map{|s| "-" * s}.join("+")
    separator = "+#{separator}+"
    output << ""
    output << separator
    output << "|#{format}|" % @cols
    output << separator
    @rows.each do |row|
      output << "|#{format}|" % row
    end
    output << separator
    output << ""
    output.join("\n")
  end

end
