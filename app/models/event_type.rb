class EventType < ActiveRecord::Base
  
  acts_as_scoped :account
  
  has_many :events
end