class CreateSettlements < ActiveRecord::Migration
  def self.up
    create_table :settlements do |t|
      t.string :name, :null => false
      t.string :kind, :null => false, :comment => ''
      t.integer :municipality_id, :null => false

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :settlements, [:account_id, :municipality_id, :deleted_at], :name => :index_settlements_account_municipality_deleted
  end

  def self.down
    drop_table :settlements
  end
end
