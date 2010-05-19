class AddResidenceToEventParticipants < ActiveRecord::Migration
  def self.up
    add_column :event_participants, :residence, :string
  end

  def self.down
    remove_column :event_participants, :residence
  end
end
