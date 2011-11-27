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
    @command == ".exit" || @command == ".quit"
  end
  
  def processed?
    @processed
  end

  def parse    
    cp = CommandParser.new(@command)
    @processed = cp.is_command?
    return unless cp.is_command?
    case cp.command
      when :find
      types = nil
      p = cp.params[0]
      if p
        types = "'U'" if p.start_with?("table")
        types = "'V'" if p.start_with?("view")
        types = "'P'" if p.start_with?("procedure")
        types = "'TF', 'IF', 'FN'" if p.start_with?("function")
      end
      find(types, types.nil? ? cp.params[0].to_s + cp.params[1].to_s : cp.params[1])  
      when :explain
      if cp.params[1].nil? || cp.params[1].empty?
        schema = 'dbo'
        object = cp.params[0]
      else
        schema = cp.params[0]
        object = cp.params[1]
      end
      explain_object schema, object
      when :use
      @connection.use cp.params[0]
    end
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
    QueryOutput.new(@connection, sql).show
    @processed = true
  end

  def show_tables
    sql = <<-EOS
      select schemas.name + '.' +  tables.name table_name
      from sys.tables 
      inner join sys.schemas on schemas.schema_id = tables.schema_id
      order by 1
EOS
    QueryOutput.new(@connection, sql).show
    @processed = true
  end

  def explain_object(schema, object)
    sql = <<-EOS
declare @object_id int, @type varchar(2), @name varchar(255)

select @object_id = o.object_id, @type = o.type, @name = s.name + '.' + o.name
from sys.objects o
inner join sys.schemas s on o.schema_id = s.schema_id
where s.name = '#{schema}' and o.name = '#{object}'

--finding object with like in name, possibly confusing, so comment out
--if @object_id is null
--  select top 1 @object_id = o.object_id, @type = o.type, @name = s.name + '.' + o.name
--  from sys.objects o
--  inner join sys.schemas s on o.schema_id = s.schema_id
--  where s.name = '#{schema}' and o.name like '#{object}%'
--  order by s.schema_id, o.name
  
if @object_id is not null
  if @type = 'U'
    exec sp_help @name
  else
    select text from syscomments where id = @object_id
else
    select 'object not found'
EOS

    QueryOutput.new(@connection, sql).show_text_or_table
    @processed = true
  end


end
