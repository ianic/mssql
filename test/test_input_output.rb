require 'minitest/unit'
require 'pp'

class TestInputOuput < MiniTest::Unit::TestCase

  def test_all
    input_files.each do |input_file_name|
      @input_file_name = input_file_name
      @actual = execute
      write_expected unless File.exists?(expected_file)
      write_actual
      @expected = expected_content
      unless @actual == @expected
        `opendiff #{expected_file} #{actual_file}`
      end
      assert @actual == @expected, "#{actual_file} differs from #{expected_file}"
    end
  end

  private

  def write_expected
    print "!! writing expected file #{expected_file}\n"
    print @actual
    print "\n"
    File.open(expected_file, "w+") do |f|
      f.puts @actual
    end
  end

  def write_actual
    File.open(actual_file, "w+") do |f|
      f.puts @actual
    end
  end

  def expected_content
    File.read expected_file
  end

  def base_name
    File.join app_root, "test/in_out", @input_file_name.gsub(".sql", "")
  end

  def expected_file
    base_name + ".expected"
  end

  def actual_file
    base_name + ".actual"
  end

  def input_files
    Dir.chdir app_root
    Dir.chdir "./test/in_out"
    Dir.glob("*.sql")
  end

  def execute
    Dir.chdir app_root
    `bin/mssql.rb -c test -i test/in_out/#{@input_file_name}`
  end

  def app_root
    @app_root ||= File.join(File.absolute_path(File.dirname(__FILE__)), "..")
  end

end
