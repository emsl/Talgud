class Event < ActiveRecord::Base
  
  acts_as_scoped :account
  
  belongs_to :event_type
  
  validates_presence_of :name
end
