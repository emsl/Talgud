class Event < ActiveRecord::Base

  acts_as_scoped :account
  acts_as_url :name, :scope => :account_id, :only_when_blank => true
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  STATUS = {:new => 'new', :published => 'published', :registration_open => 'registration_open', :registration_closed => 'registration_closed', :finished => 'finished', :denied => 'denied'}

  belongs_to :event_type
  belongs_to :manager, :class_name => 'User', :foreign_key => :manager_id
  belongs_to :location_address_county, :class_name => 'County', :foreign_key => :location_address_county_id
  belongs_to :location_address_municipality, :class_name => 'Municipality', :foreign_key => :location_address_municipality_id
  belongs_to :location_address_settlement, :class_name => 'Settlement', :foreign_key => :location_address_settlement_id
  has_many :roles, :as => :model
  has_and_belongs_to_many :languages
  
  validates_uniqueness_of :code, :scope => :account_id

  before_validation_on_create :set_defaults
  after_save :grant_manager_role

  validates_presence_of :name, :code, :url, :begins_at, :ends_at, :event_type, :manager, :status, :location_address_country_code, :location_address_county, :location_address_municipality, :max_participants
  validates_presence_of :meta_aim_description, :meta_job_description, :meta_bring_with_you, :meta_provided_for_participiants, :meta_subject_owner, :gathering_location
  validates_presence_of :languages, :message => :pick_at_least_one
  validates_numericality_of :max_participants, :greater_than => 0, :only_integer => true
  validates_each :ends_at  do |record, attr, value|
    if not record.begins_at.nil? and record.begins_at > value
      record.errors.add :ends_at, :must_be_after_begin_time
      record.errors.add :end_time, :must_be_after_begin_time
    end
  end 

  named_scope :published, :conditions => {:status => [STATUS[:published], STATUS[:registration_open], STATUS[:registration_closed]]}
  named_scope :my_events, lambda { |u| {:include => :roles, :conditions => {:roles => {:user_id => u, :role => Role::ROLE[:event_manager]}}} }
  named_scope :latest, lambda { |count| {:limit => count, :order => 'created_at DESC'} }
  #named_scope :can_manage, lambda { |u| {:include => [:manager, :location_address_county, :location_address_municipality, :location_address_settlement]}}
  default_scope :conditions => {:deleted_at => nil}

  def to_param
    url
  end
  
  def location_address
    a = [location_address_county, location_address_municipality, location_address_settlement].compact.map(&:name)
    a << location_address_street unless location_address_street.blank?
    a.join(', ')
  end

  def published?
    [STATUS[:published], STATUS[:registration_open], STATUS[:registration_closed]].include?(self.status)
  end
  
  def begin_time=(new_time)
    new_time = new_time.split(':')
    if self.begins_at
      self.begins_at = self.begins_at.change(:hour => new_time[0].to_i)
      self.begins_at = self.begins_at.change(:min => new_time[1].to_i)
    end
  end
  
  def begin_time
    begins_at.strftime('%H:%M').gsub(/^0/, '') if begins_at
  end
  
  def end_time=(new_time)
    new_time = new_time.split(':')
    if self.ends_at
      self.ends_at = self.ends_at.change(:hour => new_time[0].to_i)
      self.ends_at = self.ends_at.change(:min => new_time[1].to_i)
    end
  end

  def end_time
    ends_at.strftime('%H:%M').gsub(/^0/, '') if ends_at
  end
  
  # Tries to find user records that suit best to manage this event. It will be searched through address object. Any
  # address item (county, municipality, settlement) may have a manager associated with it. This method looks for the
  # smallest region first, thereby starting from settlement and moving up to county level.
  #
  # Method always returns an array of users rather than a single record. Please note that empty array may be returned.
  def regional_managers
    m = []    
    m = location_address_settlement.regional_managers if location_address_settlement
    m = location_address_municipality.regional_managers if location_address_municipality and m.empty?
    m = location_address_county.regional_managers if location_address_county and m.empty?
    m
  end
  
  # Returns list of users who have permissions to manage this event.
  def managers
    self.roles.all(:conditions => {:role => Role::ROLE[:event_manager]}).collect{ |r| r.user }
  end

  def vacancies
    self.max_participants
  end

  private

  def grant_manager_role
    unless Role.has_role?(Role::ROLE[:event_manager], self.manager, self)
      Role.grant_role(Role::ROLE[:event_manager], self.manager, self)
    end
  end

  def set_defaults
    self.code = CodeSequence.next_value(self).label if self.code.blank?
    self.status = 'new' if self.status.blank?
  end
end
