class Event < ActiveRecord::Base

  acts_as_scoped :account
  acts_as_url :name, :scope => :account_id, :only_when_blank => true
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  STATUS = {:new => 'new', :published => 'published', :registration_open => 'registration_open', :registration_closed => 'registration_closed', :closed => 'closed', :took_place => 'took_place', :adjustment => 'adjustment'}

  has_many :manager_roles, :as => :model, :class_name => 'Role', :conditions => {:roles => {:role => Role::ROLE[:event_manager]}}
  has_many :managers, :through => :manager_roles, :source => :user
  has_many :event_participants

  belongs_to :event_type
  belongs_to :manager, :class_name => 'User', :foreign_key => :manager_id
  belongs_to :location_address_county, :class_name => 'County', :foreign_key => :location_address_county_id
  belongs_to :location_address_municipality, :class_name => 'Municipality', :foreign_key => :location_address_municipality_id
  belongs_to :location_address_settlement, :class_name => 'Settlement', :foreign_key => :location_address_settlement_id
  has_many :roles, :as => :model
  
  has_and_belongs_to_many :languages
    
  validates_uniqueness_of :code, :scope => :account_id

  before_validation_on_create :set_defaults
  before_save :set_code

  validates_presence_of :name, :code, :url, :begins_at, :ends_at, :event_type, :manager, :status, :location_address_country_code, :location_address_county, :location_address_municipality, :max_participants
  validates_presence_of :meta_aim_description, :meta_job_description, :meta_bring_with_you, :meta_provided_for_participiants, :meta_subject_owner, :gathering_location, :meta_subject_protegee
  validates_presence_of :languages, :message => :pick_at_least_one
  validates_numericality_of :max_participants, :greater_than => 0, :only_integer => true
  validates_each :ends_at  do |record, attr, value|
    if not record.begins_at.nil? and record.begins_at > value
      record.errors.add :ends_at, :must_be_after_begin_time
      record.errors.add :end_time, :must_be_after_begin_time
    end
  end
  
  validates_each :location_address_municipality  do |record, attr, value|
    if not record.location_address_municipality.nil?
      record.errors.add :location_address_municipality, :inclusion unless record.location_address_county.municipalities.include?(value)
    end
  end

  validates_each :location_address_settlement  do |record, attr, value|
    if not record.location_address_settlement.nil? and record.location_address_municipality
      record.errors.add :location_address_settlement, :inclusion unless record.location_address_municipality.settlements.include?(value)
    end
  end

  named_scope :published, :conditions => {:status => [STATUS[:published], STATUS[:registration_open], STATUS[:registration_closed]]}
  named_scope :my_events, lambda { |u| {:include => :roles, :conditions => {:roles => {:user_id => u, :role => Role::ROLE[:event_manager]}}} }
  named_scope :latest, lambda { |count| {:limit => count, :order => 'events.id DESC'} }
  named_scope :can_manage, lambda { |u| { :conditions => ['EXISTS (SELECT 1 FROM roles WHERE user_id = ? AND (role = ? AND ((model_type = ? AND model_id = events.location_address_county_id) OR (model_type = ? AND model_id = events.location_address_municipality_id) OR (model_type = ? AND model_id = events.location_address_settlement_id)) OR role = ? OR (role = ? AND (model_type = ? AND model_id = events.id))))',
     (u ? u.id : nil) , 'regional_manager', 'County', 'Municipality', 'Settlement', 'account_manager', 'event_manager', 'Event'] }}
  default_scope :conditions => {:deleted_at => nil}
  named_scope :sorted, :order => {:name => ' ASC'}
  named_scope :by_manager_name, lambda { |u| {:conditions => ['UPPER(users.firstname) LIKE UPPER(?) OR UPPER(users.lastname) LIKE UPPER(?)', "#{u}%", "#{u}%"], :include => :managers} unless u.blank? }
  named_scope :by_language_code, lambda { |l| {:conditions => ['languages.code = ?', l], :include => :languages} unless l.blank? }
  

  def self.class_role_symbols
    [:event_manager]
  end
  
  def label
    [self.code, self.name] * ', '
  end

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
  
  def can_register?
    vacancies? && self.status == STATUS[:registration_open]
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
    m = location_address_settlement.managers if location_address_settlement
    m = location_address_municipality.managers if location_address_municipality and m.empty?
    m = location_address_county.managers if location_address_county and m.empty?
    m
  end
  
  def vacancies
    [self.max_participants - self.current_participants, 0].max
  end

  def vacancies?
    self.vacancies > 0
  end

  # Run's automatic state change jobs. 
  # Event statuses that will be affected.
  #
  # Published -> Registration opened on registration begins at date
  # Registration opened -> Registration closed on registration ends at date
  # Registration closed -> Took place after ends at date + 2 days.
  def self.run_state_jobs
    Event.update_all({:status => STATUS[:registration_closed]}, ["status = ? AND current_participants >= max_participants", STATUS[:registration_open]])
    Event.update_all({:status => STATUS[:took_place]}, ["status = ? AND ends_at <= ?", STATUS[:registration_closed], 2.days.ago])
  end

  private

  def set_defaults
    self.status = 'new' if self.status.blank?
    self.code = ActiveSupport::SecureRandom.base64(16).upcase # temporary code
  end
  
  def set_code
    self.code = CodeSequence.next_value(self).label if new_record?
  end
end
