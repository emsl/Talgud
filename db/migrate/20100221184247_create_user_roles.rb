class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles, :force => true do |t|
      t.references :role, :null => false
      t.references :user, :null => false
      t.references :model, :polymorphic => true, :references => nil

      t.datetime :valid_from
      t.datetime :valid_to
      
      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    add_index :user_roles, [:account_id, :role_id, :user_id, :model_type, :model_id, :deleted_at], :name => :index_user_roles_uk, :unique => true
  end

  def self.down
    drop_table :user_roles
  end
end
