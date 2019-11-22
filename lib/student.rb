require_relative "../config/environment.rb"
require "pry"

class Student

  attr_accessor :id, :name, :grade
  
  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.new_from_db(row)
    x = self.new(row)
    x.id = row[0]
    x.name =  row[1]
    x.grade = row[2]
    x
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM students
    SQL
 
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL
 
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  def self.create(name, grade)
    x = Student.new(name, grade)
    x.save
    x
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
