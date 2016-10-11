class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :hits do |t|
		t.string :user_agent
		t.string :path_info
		t.string :remote_addr
		t.string :http_referrer
		t.string :status
		t.datetime :visited_at
    end
    create_table :advertisers do |t|
        t.string :company_name
        t.string :referrer_url
        t.decimal :cost_per_click,
                 :precision => 9, :scale => 2
    end
  end

  def self.down
    drop_table :hits
    drop_table :advertisers
  end
end
