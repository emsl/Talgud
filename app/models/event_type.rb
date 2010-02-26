class EventType < ActiveRecord::Base
  
  acts_as_scoped :account
  
  has_many :events
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  default_scope :conditions => {:deleted_at => nil}
end