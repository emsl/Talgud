class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.string :domain

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
    end
  end

  def self.down
    drop_table :accounts
  end
end
