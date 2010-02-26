class Event < ActiveRecord::Base

  acts_as_scoped :account
  acts_as_url :name, :scope => :account_id, :only_when_blank => true
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude

  STATUS = {:new => 'new', :published => 'published', :registration_open => 'registration_open', :registration_closed => 'registration_closed', :finished => 'finished', :denied => 'denied'}
  PROTEGEE_TYPES = {:nature_conservation => 'nature_conservation', :heritage => 'heritage'}

  belongs_to :event_type
  belongs_to :manager, :class_name => 'User', :foreign_key => :manager_id
  belongs_to :location_address_county, :class_name => 'County', :foreign_key => :location_address_county_id
  belongs_to :location_address_municipality, :class_name => 'Municipality', :foreign_key => :location_address_municipality_id
  belongs_to :location_address_settlement, :class_name => 'Settlement', :foreign_key => :location_address_settlement_id
  has_many :roles, :as => :model

  before_validation_on_create :set_defaults
  after_save :grant_manager_role

  validates_presence_of :name, :code, :url, :begins_at, :ends_at, :event_type, :manager, :status, :location_address_country_code, :location_address_county, :location_address_municipality, :max_participants
  validates_numericality_of :max_participants, :greater_than => 0, :only_integer => true
  validates_each :ends_at  do |record, attr, value|
    record.errors.add attr, 'peab olema tulevikus' if not record.begins_at.nil? and record.begins_at > value
  end 

  named_scope :published, :conditions => {:status => [STATUS[:published], STATUS[:registration_open], STATUS[:registration_closed]]}
  named_scope :my_events, lambda { |u| {:include => :roles, :conditions => {:roles => {:user_id => u, :role => Role::ROLE[:event_manager]}}} }
  named_scope :latest, lambda { |count| {:limit => count, :order => 'created_at DESC'} }
  default_scope :conditions => {:deleted_at => nil}

  def to_param
    url
  end

  def location_address
    [location_address_county, location_address_municipality, location_address_settlement].compact.map(&:name).join(', ')
  end

  def published?
    [STATUS[:published], STATUS[:registration_open], STATUS[:registration_closed]].include?(self.status)
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

  private

  def grant_manager_role
    unless Role.has_role?(Role::ROLE[:event_manager], self.manager, self)
      Role.grant_role(Role::ROLE[:event_manager], self.manager, self)
    end
  end

  def set_defaults
    self.code = ActiveSupport::SecureRandom.base64(6).upcase
    self.status = 'new' if self.status.blank?
  end
end
