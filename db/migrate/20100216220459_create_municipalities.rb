class CreateMunicipalities < ActiveRecord::Migration
  def self.up
    create_table :municipalities do |t|
      t.string :name, :null => false
      t.string :kind, :null => false
      t.integer :county_id, :null => false

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :municipalities, [:account_id, :county_id, :deleted_at], :name => :index_municipalities_account_cocunty_deleted
  end

  def self.down
    drop_table :municipalities
  end
end
