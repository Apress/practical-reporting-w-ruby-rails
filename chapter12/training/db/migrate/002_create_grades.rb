class CreateGrades < ActiveRecord::Migration
  def self.up
    create_table :grades do |t|
      t.column :salesperson_id, :integer
      t.column :class_id, :integer
      t.column :percentage_grade, :integer
      t.column :took_class_at, :datetime
    end
  end

  def self.down
    drop_table :grades
  end
end

