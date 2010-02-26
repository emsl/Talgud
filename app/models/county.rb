class County < ActiveRecord::Base
  
  acts_as_scoped :account
  
  has_many :municipalities
  has_many :roles, :as => :model
  has_many :regional_manager_roles, :as => :model, :class_name => 'Role', :conditions => {:role => Role::ROLE[:regional_manager]}
  has_many :regional_managers, :through => :regional_manager_roles, :source => :user
  
  validates_presence_of :name
  
end
