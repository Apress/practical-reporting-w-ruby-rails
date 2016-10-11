class CreateSalespeople < ActiveRecord::Migration
  def self.up
    create_table :salespeople do |t|
      t.column :name, :string, :limit=>45
      t.column :employer, :string, :limit=>45
    end
  end

  def self.down
    drop_table :salespeople
  end
end
