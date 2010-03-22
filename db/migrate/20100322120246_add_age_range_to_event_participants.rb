class AddAgeRangeToEventParticipants < ActiveRecord::Migration
  def self.up
    add_column :event_participants, :age_range, :integer
  end

  def self.down
    remove_column :event_participants, :age_range
  end
end
