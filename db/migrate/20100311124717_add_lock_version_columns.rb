class AddLockVersionColumns < ActiveRecord::Migration
  def self.up
    add_column :accounts, :lock_version, :integer
    add_column :counties, :lock_version, :integer
    add_column :municipalities, :lock_version, :integer
    add_column :settlements, :lock_version, :integer
    add_column :users, :lock_version, :integer
    add_column :languages, :lock_version, :integer
    add_column :roles, :lock_version, :integer
    add_column :event_types, :lock_version, :integer
    add_column :events, :lock_version, :integer
    add_column :event_participants, :lock_version, :integer
    add_column :assets, :lock_version, :integer
    add_column :events_languages, :lock_version, :integer
  end

  def self.down
    remove_column :events_languages, :lock_version
    remove_column :assets, :lock_version
    remove_column :event_participants, :lock_version
    remove_column :events, :lock_version
    remove_column :event_types, :lock_version
    remove_column :roles, :lock_version
    remove_column :languages, :lock_version
    remove_column :users, :lock_version
    remove_column :settlements, :lock_version
    remove_column :municipalities, :lock_version
    remove_column :counties, :lock_version
    remove_column :accounts, :lock_version
  end
end
