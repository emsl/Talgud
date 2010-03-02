class CreateCodeSequences < ActiveRecord::Migration
  def self.up
    create_table :code_sequences, :force => true do |t|
      t.column :code, :string, :null => false, :comment => 'Sequence unique code.'
      t.column :sequence, :string, :null => false, :comment => 'Sequence pattern.'
      t.column :value, :integer, :null => false, :comment => 'Sequence value.'
      
      t.lock_version
      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :code_sequences, [:account_id, :code, :sequence, :deleted_at], :name => :index_code_sequences, :unique => true
  end

  def self.down
    drop_table :code_sequences
  end
end
