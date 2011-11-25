class Command

  def initialize(command, connection)
    @connection = connection
    @command = command.strip.downcase
    @processed = false
    parse
  end
  
  attr_reader :processed

  def self.go?(command)
    command.strip.downcase == "go"
  end

  def exit?
    @command == "exit"
  end
  
  def processed?
    @processed
  end

  def parse
    if @command.start_with?("find")
      match = @command.match /find\s*(\w*)\s*([\w.]*)/
      types = nil
      types = "'U'" if match[1].start_with?("table")
      types = "'V'" if match[1].start_with?("view")
      types = "'P'" if match[1].start_with?("procedure")
      types = "'TF', 'IF', 'FN'" if match[1].start_with?("function")
      find(types, types.nil? ? match[1].to_s + match[2].to_s : match[2])  
    end
    if @command.start_with?("explain")
      match = @command.match /explain\s+(\w*)\.*(\w*)/
      if match[2].nil? || match[2].empty?
        schema = 'dbo'
        object = match[1]
      else
        schema = match[1]
        object = match[2]
      end
      explain_object schema, object
    end
    show_tables if @command.start_with?("show tables")
  end

  def find(types, name)
    types = "'TF', 'IF', 'FN', 'P', 'V', 'U'" if types.nil?
    sql = <<-EOS
    	select 
    		--db_name() [database],
    		case when type in ('TF', 'IF', 'FN') then 'function'
    			when type in ('P') then 'procedure'
    			when type in ('V') then 'view'
    			when type in ('U') then 'table'
    			else '???'
    		end type,
    		s.name [schema],
    		o.name
    	from sys.objects o
    	inner join sys.schemas s on o.schema_id = s.schema_id
    	where 
    		type in ( #{types} )
    		and is_ms_shipped = 0
        
        and s.name + "." + o.name like '%#{name}%'
    	order by 
    		case when o.schema_id = 1 then 0 else 1 end, --prvo dbo schema
    		case when type in ('TF', 'IF', 'FN') then 4
    			when type in ('P') then 3
    			when type in ('V') then 2
    			when type in ('U') then 1
    			else 100
    		end,		
    		s.name, o.name
EOS
    @connection.show(sql)
    @processed = true
  end

  def show_tables
    sql = <<-EOS
      select schemas.name + '.' +  tables.name table_name
      from sys.tables 
      inner join sys.schemas on schemas.schema_id = tables.schema_id
      order by 1
EOS
    @connection.show sql
    @processed = true
  end

  def explain_object(schema, object)
    sql = <<-EOS
declare @object_id int, @type varchar(2)
select @object_id = o.object_id, @type = o.type
from sys.objects o
inner join sys.schemas s on o.schema_id = s.schema_id
where s.name = '#{schema}' and o.name = '#{object}'
order by s.name, o.name
--select @object_id, @type
if @type = 'U'
  exec sp_help '#{schema}.#{object}'
else
  select text from syscomments where id = @object_id
EOS


#     sql = <<-EOS
# declare @object_id int
# select @object_id = o.object_id
# from sys.objects o
# inner join sys.schemas s on o.schema_id = s.schema_id
# where s.name = '#{schema}' and o.name = '#{object}'
# order by s.name, o.name
# select text from syscomments where id = @object_id
# EOS
    @connection.show_text_or_table(sql)
    @processed = true
  end


end
