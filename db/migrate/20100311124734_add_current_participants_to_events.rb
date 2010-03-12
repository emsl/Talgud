class AddCurrentParticipantsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :current_participants, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :events, :current_participants
  end
end
