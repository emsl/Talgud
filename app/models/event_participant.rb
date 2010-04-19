class EventParticipant < ActiveRecord::Base

  acts_as_scoped :account

  default_scope :conditions => {:deleted_at => nil}

  belongs_to :event
  belongs_to :account
  belongs_to :event_participant
  has_many :children, :class_name => 'EventParticipant', :foreign_key => :event_participant_id
  
  accepts_nested_attributes_for :children, :reject_if => lambda { |c| [:firstname, :lastname, :email, :phone].all?{ |a| c[a].blank? } }, :allow_destroy => true

  before_validation_on_create :ensure_event_association
  after_save :recalculate_event_current_participants

  validates_presence_of :firstname, :lastname, :event, :age_range
  validates_presence_of :email, :phone, :if => :parent?
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true
  validates_each :notes, :tellafriend_emails do |record, attrib, value|
    record.errors.add attrib, :value_not_accepted if value =~ /\<a href|\[url=|\[link=/
  end
  
  named_scope :ordered_by_name, :order => 'firstname ASC, lastname ASC'
  named_scope :parents, :conditions => {:event_participant_id => nil}
  
  named_scope :can_manage, lambda { |u| {:include => [:event], :conditions => ['EXISTS (SELECT 1 FROM roles WHERE user_id = ? AND ((role = ? AND ((model_type = ? AND model_id = events.location_address_county_id) OR (model_type = ? AND model_id = events.location_address_municipality_id) OR (model_type = ? AND model_id = events.location_address_settlement_id)) OR role = ? OR (role = ? AND model_type = ? AND model_id = events.id))))',
     (u ? u.id : nil) , 'regional_manager', 'County', 'Municipality', 'Settlement', 'account_manager', 'event_manager', 'Event'] }}
    
  def parent?
    self.event_participant.nil?
  end
  
  def participants_count
    1 + self.children.all.count 
  end
  
  def children_valid?
    children.all? { |c| c.valid? }
  end

  def participant_name
    [firstname, lastname] * ' '
  end

  # Returns full name for given participant.
  def name
    [firstname, lastname] * ' '
  end
  
  def parent_name
    self.event_participant ? self.event_participant.name : nil
  end

  def recommend_emails
    return [] if tellafriend_emails.blank?
    res = tellafriend_emails.split(',').inject(Array.new) do |memo, item|
      item = item.strip
      memo << item if item =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
      memo
    end
    res.uniq
  end
  
  def destroy
    update_attribute(:deleted_at, Time.now)
  end

  private
  
  def ensure_event_association
    self.event = event_participant.event if event.nil? and new_record? and not parent?
  end

  def recalculate_event_current_participants
    self.transaction do
      event.lock!
      event.update_attribute(:current_participants, event.event_participants.count)
    end
  end
end
