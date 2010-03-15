class EventParticipant < ActiveRecord::Base

  acts_as_scoped :account

  default_scope :conditions => {:deleted_at => nil}

  belongs_to :event
  belongs_to :account
  belongs_to :event_participant

  after_save :recalculate_event_current_participants

  validates_presence_of :firstname, :lastname, :event
  validates_presence_of :email, :phone, :if => :parent?
  
  validates_each :event  do |record, attr, value|
    if record.event.vacancies == 0 
      record.errors.add :firstname, :no_vacancies
    end
  end 

  def parent?
    self.event_participant.nil?
  end

  def participant_name
    [firstname, lastname] * ' '
  end

  def recommend_emails
    res = tellafriend_emails.split(',').inject(Array.new) do |memo, item|
      item = item.strip
      memo << item if item =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
      memo
    end
    res.uniq
  end

  private

  def recalculate_event_current_participants
    self.transaction do
      event.lock!
      event.update_attribute(:current_participants, event.event_participants.count)
    end
  end
end
