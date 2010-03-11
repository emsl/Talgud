class AddCurrentParticipantsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :current_participants, :string
  end

  def self.down
    remove_column :events, :current_participants
  end
end
