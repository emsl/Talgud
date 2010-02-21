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
    
    add_index :event_participants, [:account_id, :event_id, :deleted_at]
    add_index :event_participants, [:event_participant_id, :deleted_at]
  end

  def self.down
    drop_table :event_participants
  end
end
