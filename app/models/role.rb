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

  named_scope :can_manage_events, lambda { |u| { :conditions => ['role = ? AND exists(SELECT 1 FROM roles r, events e WHERE ((r.model_type = ? AND r.model_id = e.location_address_county_id) OR (r.model_type = ? AND r.model_id = e.location_address_municipality_id) OR (r.model_type = ? AND r.model_id = e.location_address_settlement_id)) AND r.user_id = ? AND r.role = ? AND roles.model_id = e.id)', 'event_manager', 'County', 'Municipality', 'Settlement', u.id, 'regional_manager'] }}

  def self.grant_role(role, user, m)
    Role.create!(:role => role, :user => user, :model => m, :account => Account.current)
  end
  
  def self.has_role?(role, user, m)    
    not self.first(:conditions => {:model_type => m.class.name, :model_id => m.id, :role => role, :user_id => user}).nil?
  end
end
