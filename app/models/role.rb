class Role < ActiveRecord::Base
  
  acts_as_scoped :account

  ROLE = [:guest, :user, :system_administrator, :account_manager, :regional_manager, :event_manager, :event_participant]
  
  belongs_to :user
end
