class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
    end
  end

  def self.down
    drop_table :stories
  end
end
