class EventParticipant < ActiveRecord::Base

  acts_as_scoped :account

  default_scope :conditions => {:deleted_at => nil}

  belongs_to :event
  belongs_to :account
  belongs_to :event_participant

  after_save :recalculate_event_current_participants

  validates_presence_of :firstname, :lastname, :event
  validates_presence_of :email, :phone, :if => :parent?

  def parent?
    self.event_participant.nil?
  end
  
  def recommend_emails
    []
  end

  private

  def recalculate_event_current_participants
    self.transaction do
      self.event.lock!
      self.event.current_participants = self.event.event_participants.size
    end
  end
end
