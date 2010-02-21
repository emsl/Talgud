class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :code, :null => false

      t.datetime :deleted_at
      t.timestamps
      t.userstamps(true)
    end
    add_index :roles, [:code, :deleted_at], :name => 'index_roles_uk', :unique => true
    
    # guest - autentimata kasutaja
    # user - autenditud kasutaja
    # system_administrator - süsteemi administraator
    # account_manager - konto omanik ja registrite haldur
    # regional_manager - haldusala administraator
    # event_manager - kindla talgu sündmuse administraator
    # event_participant - talgu osalemise registreerija
    
    %w{guest user system_administrator account_manager regional_manager event_manager event_participant}.each do |role|
      Role.create! :code => role
    end
  end

  def self.down
    drop_table :roles
  end
end
