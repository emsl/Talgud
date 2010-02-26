class Settlement < ActiveRecord::Base
  
  acts_as_scoped :account

  KIND = [:alevik, :alev, :kyla, :linnaosa, :vallasisene_linn]
  
  belongs_to :municipality
  has_many :roles, :as => :model
  has_many :regional_manager_roles, :as => :model, :class_name => 'Role', :conditions => {:role => Role::ROLE[:regional_manager]}
  has_many :regional_managers, :through => :regional_manager_roles, :source => :user
  
  validates_presence_of :name, :kind, :municipality
  
  default_scope :conditions => {:deleted_at => nil}

end
