class Role < ActiveRecord::Base
  
  acts_as_scoped :account

  ROLE = {
    :guest => 'guest', :user => 'user', :system_administrator => 'system_administrator', :account_manager => 'account_manager',
    :regional_manager => 'regional_manager', :event_manager => 'event_manager', :event_participant => 'event_participant'
  }
  
  belongs_to :user
  belongs_to :model, :polymorphic => true
  
  validates_presence_of :role, :user, :model, :account
  
  named_scope :for_model, lambda { |m| {:conditions => {:model => m}}}
end
