class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :code
      t.references :user
      t.references :model, :polymorphic => true, :references => nil

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
    end
    
    add_index :roles, [:code, :user_id, :model_type, :model_id, :deleted_at], :unique => true    
  end

  def self.down
    drop_table :roles
  end
end
