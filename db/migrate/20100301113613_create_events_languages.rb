class CreateEventsLanguages < ActiveRecord::Migration
  def self.up
    create_table :events_languages, :id => false do |t|
      t.integer :event_id, :null => false
      t.integer :language_id, :null => false
      t.integer :account_id, :null => false
      t.timestamps
      t.userstamps(true)
    end
  end

  def self.down
    drop_table :events_languages
  end
end
