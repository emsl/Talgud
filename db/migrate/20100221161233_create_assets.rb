class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :attachment_file_name, :null => false
      t.string :attachment_content_type, :null => false
      t.integer :attachment_file_size, :null => false
      t.datetime :attachment_updated_at      
      t.references :model, :polymorphic => true, :references => nil

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :assets, [:account_id, :attachment_file_name, :model_id, :model_type, :deleted_at], :name => :index_account_attachment_model_deleted
  end

  def self.down
    drop_table :assets
  end
end
