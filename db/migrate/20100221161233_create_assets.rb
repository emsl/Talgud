class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at      
      t.references :model, :polymorphic => true, :references => nil

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
  end

  def self.down
    drop_table :assets
  end
end
