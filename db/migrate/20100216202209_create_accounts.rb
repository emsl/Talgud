class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name, :null => false
      t.string :domain, :null => false

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
    end
    
    add_index :accounts, [:domain, :deleted_at], :name => :index_accounts_uk, :unique => true
  end

  def self.down
    drop_table :accounts
  end
end
