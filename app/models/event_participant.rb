class EventParticipant < ActiveRecord::Base
  
  acts_as_scoped :account
  
  default_scope :conditions => {:deleted_at => nil}
  
  belongs_to :event
  belongs_to :account
  
  def parent?
    self.event_participant.nil?
  end
end
