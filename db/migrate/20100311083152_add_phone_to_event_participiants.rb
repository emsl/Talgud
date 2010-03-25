class AddPhoneToEventParticipiants < ActiveRecord::Migration
  def self.up
    add_column :event_participants, :phone, :string
    rename_column :event_participants, :invite_emails, :tellafriend_emails
  end

  def self.down
    rename_column :event_participants, :tellafriend_emails, :invite_emails
    remove_column :event_participants, :phone
  end
end
