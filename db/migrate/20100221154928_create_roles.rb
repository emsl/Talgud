class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.string :code
      t.references :user
      t.references :model, :polymorphic => true, :references => nil

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
    end
  end

  def self.down
    drop_table :roles
  end
end
