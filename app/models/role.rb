class Role < ActiveRecord::Base
  acts_as_scoped :account

  ROLE = {
    :guest => 'guest', :system_administrator => 'system_administrator', :account_manager => 'account_manager',
    :regional_manager => 'regional_manager', :event_manager => 'event_manager', :event_participant => 'event_participant'
  }
  
  belongs_to :user
  belongs_to :model, :polymorphic => true
  
  validates_presence_of :role, :user, :model, :account
  validates_uniqueness_of :role, :scope => [:user_id, :model_type, :model_id, :account_id] 
  
  default_scope :conditions => {:deleted_at => nil}
  named_scope :sorted, :order => {:role => ' ASC'}
  
  def self.grant_role(role, user, m)
    Role.create!(:role => role, :user => user, :model => m, :account => Account.current)
  end
  
  def self.has_role?(role, user, m)    
    not self.first(:conditions => {:model_type => m.class.name, :model_id => m.id, :role => role, :user_id => user}).nil?
  end
end
