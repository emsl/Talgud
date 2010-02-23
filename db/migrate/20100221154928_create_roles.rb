class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, :force => true do |t|
      t.string :role, :null => false
      t.references :user, :null => false
      t.references :model, :polymorphic => true, :references => nil

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    add_index :roles, [:account_id, :role, :user_id, :model_type, :model_id, :deleted_at], :name => :index_roles_uk, :unique => true
  end

  def self.down
    drop_table :roles
  end
end
