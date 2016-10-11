class CreateAdResults < ActiveRecord::Migration
  def self.up
    create_table :ad_results do |t|
    end
  end

  def self.down
    drop_table :ad_results
  end
end
