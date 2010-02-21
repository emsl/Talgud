class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :code

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :languages, [:account_id, :code, :deleted_at], :name => :index_languages_account_code_deleted, :unique => true
    
    create_table :languages_users, :id => false do |t|
      t.integer :language_id, :null => false
      t.integer :user_id, :null => false
    end
    
    add_index :languages_users, [:language_id, :user_id], :name => :index_languages_users_language_user, :unique => true
  end

  def self.down
    drop_table :languages
    drop_table :languages_users
  end
end
