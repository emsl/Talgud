class CreateCounties < ActiveRecord::Migration
  def self.up
    create_table :counties do |t|
      t.string :name

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :counties, [:account_id, :deleted_at], :name => :index_countries_account_deleted
  end

  def self.down
    drop_table :counties
  end
end
