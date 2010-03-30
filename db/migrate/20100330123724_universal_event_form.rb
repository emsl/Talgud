class UniversalEventForm < ActiveRecord::Migration
  def self.up
    add_column :events, :registration_text, :text                 # lisainfo talgule registreerijale, mis saadetakse ka koos emailiga
    add_column :events, :registration_notes_title, :text        # lisainfo tiitel talgutele registreerimise vormis
    add_column :events, :registration_begins_at, :datetime, :null => false # registreerimise algus
    add_column :events, :registration_ends_at, :datetime, :null => false   # registreerimise lõpp
    add_column :events, :meta_food_info, :text                  # toitlustamine
    add_column :events, :meta_sleep_info, :text                 # ööbimise info
    add_column :events, :meta_transport_info, :text             # transport
    add_column :events, :meta_cash_info, :text                  # osavõtutasu
  end

  def self.down
    remove_column :events, :meta_cash_info
    remove_column :events, :meta_transport_info
    remove_column :events, :meta_sleep_info
    remove_column :events, :meta_food_info
    remove_column :events, :registration_begins_at
    remove_column :events, :registration_ends_at
    remove_column :events, :registration_notes_title
    remove_column :events, :registration_text
  end
end
