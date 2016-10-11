class CreateTrainingClasses < ActiveRecord::Migration
  def self.up
    create_table :training_classes do |t|
      t.column :name, :string, :limit=>45
    end
  end

  def self.down
    drop_table :training_classes
  end
end
