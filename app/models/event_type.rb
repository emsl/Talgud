class EventType < ActiveRecord::Base
  
  acts_as_scoped :account
  
  has_many :events
  
  validates_presence_of :name
end