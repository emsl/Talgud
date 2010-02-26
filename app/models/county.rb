class County < ActiveRecord::Base
  
  acts_as_scoped :account
  
  has_many :municipalities
  
  validates_presence_of :name
  
  default_scope :conditions => {:deleted_at => nil}
end
