class Account < ActiveRecord::Base

  cattr_accessor :current

  validates_presence_of :name, :domain
  validates_uniqueness_of :domain, :case_sensitive => false
  has_many :manager_roles, :as => :model, :class_name => 'Role', :conditions => {:role => Role::ROLE[:account_manager]}
  has_many :managers, :through => :manager_roles, :source => :user

  default_scope :conditions => {:deleted_at => nil}
  named_scope :sorted, :order => {:name => ' ASC'}

  has_many :roles, :as => :model

  def self.class_role_symbols
    [:account_manager]
  end

  def label
    self.name
  end
end
