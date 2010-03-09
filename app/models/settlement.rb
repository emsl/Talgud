class Settlement < ActiveRecord::Base
  
  acts_as_scoped :account

  KIND = [:alevik, :alev, :kyla, :linnaosa, :vallasisene_linn]
  
  belongs_to :municipality
  has_many :roles, :as => :model
  has_many :manager_roles, :as => :model, :class_name => 'Role', :conditions => {:role => Role::ROLE[:regional_manager]}
  has_many :managers, :through => :manager_roles, :source => :user
  
  validates_presence_of :name, :kind, :municipality
  
  default_scope :conditions => {:deleted_at => nil}

  def self.class_role_symbols
    [:regional_manager]
  end  
end
