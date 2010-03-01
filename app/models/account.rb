class Account < ActiveRecord::Base
  
  cattr_accessor :current
  
  validates_presence_of :name, :domain
  validates_uniqueness_of :domain, :case_sensitive => false
  
  default_scope :conditions => {:deleted_at => nil}
  
  has_many :roles, :as => :model
end