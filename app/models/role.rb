class Role < ActiveRecord::Base
  
  acts_as_scoped :account

  ROLE = {
    :guest => 'guest', :user => 'user', :system_administrator => 'system_administrator', :account_manager => 'account_manager',
    :regional_manager => 'regional_manager', :event_manager => 'event_manager', :event_participant => 'event_participant'
  }
  
  belongs_to :user
  
  validates_presence_of :role, :user, :model
end
