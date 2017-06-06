require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    table_data = DBConnection.execute2(<<-SQL)
      SELECT * 
      FROM #{self.table_name}
    SQL
    @columns = table_data.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) { attributes[col] }
      define_method("#{col}=") { |val| attributes[col] = val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    query_data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name} 
    SQL
    self.parse_all(query_data)
  end

  def self.parse_all(results)
    results.map {|result| self.new(result) }
  end

  def self.find(id)
    query_data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
      WHERE id = #{id}
    SQL
    self.parse_all(query_data).first
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * (attributes.length + 1)).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
