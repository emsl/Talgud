class CreateEventParticipants < ActiveRecord::Migration
  def self.up
    create_table :event_participants do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.text :notes
      t.text :invite_emails
      t.references :event_participant
      t.references :event

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
      t.references :account, :null => false
    end
    
    add_index :event_participants, [:account_id, :event_id, :deleted_at], :name => :index_event_participants_account_event_deleted
    add_index :event_participants, [:event_participant_id, :deleted_at], :name => :index_event_participants_ep_deleted
  end

  def self.down
    drop_table :event_participants
  end
end
