class AccountPreferences < ActiveRecord::Migration
  def self.up
    add_column :accounts, :em_publish_event, :boolean, :default => false, :null => false, :comment => 'Event manager can publish event?'
    Account.reset_column_information
    
    Account.all.each do |account|
      account.em_publish_event = false
      account.save!
    end
  end

  def self.down
    remove_column :accounts, :em_publish_event
  end
end
