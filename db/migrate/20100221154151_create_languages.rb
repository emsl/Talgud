class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :code
      t.string :name

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :languages, [:account_id, :code, :deleted_at], :name => :index_languages_account_code_deleted, :unique => true
  end

  def self.down
    drop_table :languages
  end
end
