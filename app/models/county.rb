class County < ActiveRecord::Base
  
  acts_as_scoped :account
  
  has_many :municipalities
  has_many :roles, :as => :model
  has_many :manager_roles, :as => :model, :class_name => 'Role', :conditions => {:role => Role::ROLE[:regional_manager]}
  has_many :managers, :through => :manager_roles, :source => :user
  
  validates_presence_of :name
  
  default_scope :conditions => {:deleted_at => nil}, :order => {:name => ' ASC'}
  
  def self.class_role_symbols
    [:regional_manager]
  end
  
  def label
    self.name
  end
  
end
