class EventParticipant < ActiveRecord::Base
  
  acts_as_scoped :account
  
  default_scope :conditions => {:deleted_at => nil}
end
