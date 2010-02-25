class Role < ActiveRecord::Base
  
  acts_as_scoped :account

  ROLE = {
    :guest => 'guest', :user => 'user', :system_administrator => 'system_administrator', :account_manager => 'account_manager',
    :regional_manager => 'regional_manager', :event_manager => 'event_manager', :event_participant => 'event_participant'
  }
  
  belongs_to :user
  belongs_to :model, :polymorphic => true
  
  validates_presence_of :role, :user, :model, :account
  
  #named_scope :role_for_model, lambda { |r, m| {:conditions => {:model => m, :role => r}}}
  
  def self.grant_role(role, user, m)
    self.new(:role => role, :user => user, :model => m)
  end
  
  def self.has_role?(role, user, m)
    self.find(:conditions => {:model => m, :role => role, :user => user}).nil?
  end
end
