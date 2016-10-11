class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :actors do |t|
      t.column :name, :text, :length=>45
      t.column :phone, :text, :length=>13
    end
    create_table :projects do |t|
      t.column :name, :text, :length=>25
    end
    create_table :rooms do |t|
      t.column :name, :text, :length=>25
    end
    create_table :bookings do |t|
      t.column :actor_id, :integer
      t.column :room_id, :integer
      t.column :project_id, :integer
      t.column :booked_at, :datetime
    end
  end

  def self.down
    drop_table :actors
    drop_table :projects
    drop_table :rooms
    drop_table :bookings
  end
end

