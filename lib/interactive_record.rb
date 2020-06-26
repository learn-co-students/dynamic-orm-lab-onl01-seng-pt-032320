require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name 
    "#{self.to_s.downcase}s"
  end
  
  def self.column_names
    sql = "pragma table_info('#{table_name}')"

    names = DB[:conn].execute(sql)
    names.map do |row|
      row["name"]
    end
  end
  
  def initialize(options={})
    options.each { |initialize, value|
      self.send("#{initialize}=", value)
    }
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.join(", ")
  end
  
  def values_for_insert
    array = []
    self.class.column_names.each do |col_name|
      if send(col_name) != nil
        array << "'#{send(col_name)}'"
      end
    end
    array.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    sql = "SELECT last_insert_rowid() FROM #{table_name_for_insert}"
    @id = DB[:conn].execute(sql)[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end
  
  def self.find_by(whatever)
    sql = "SELECT * FROM #{self.table_name} WHERE #{whatever.keys[0].to_s} = '#{whatever.values[0].to_s}'"
    DB[:conn].execute(sql)
end
end