class Municipality < ActiveRecord::Base
  
  acts_as_scoped :account
  
  KIND = [:linn, :vald]
  
  belongs_to :county
  has_many :settlements
  has_many :roles, :as => :model
  has_many :regional_manager_roles, :as => :model, :class_name => 'Role', :conditions => {:role => Role::ROLE[:regional_manager]}
  has_many :regional_managers, :through => :regional_manager_roles, :source => :user
  
  validates_presence_of :name, :kind, :county
  
  default_scope :conditions => {:deleted_at => nil}

end
