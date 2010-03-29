class AccountPreferences < ActiveRecord::Migration
  def self.up
    add_column :accounts, :em_publish_event, :boolean, :default => false, :nullable => false, :comment => 'Event manager can publish event?'
    add_column :accounts, :rm_event_notifications, :boolean, :default => true, :nullable => false, :comment => 'Send event notifications to regional manager.'
    add_column :accounts, :em_edit_mail_templates, :boolean, :default => false, :nullable => false, :comment => 'Evebt manager can edit event templates.'
    Account.reset_column_information
    
    Account.all.each do |account|
      account.em_edit_mail_templates = false
      account.em_publish_event = false
      account.rm_event_notifications = true
      account.save!
    end
  end

  def self.down
    remove_column :accounts, :em_edit_mail_templates
    remove_column :accounts, :rm_event_notifications
    remove_column :accounts, :em_publish_event
  end
end
