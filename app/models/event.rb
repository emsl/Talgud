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
  
  before_validation_on_create :set_defaults
  
  validates_presence_of :name, :code, :url, :begins_at, :ends_at, :event_type, :manager, :status, :location_address_country_code, :location_address_county, :location_address_municipality, :max_participants
  validates_numericality_of :max_participants, :greater_than => 0, :only_integer => true
  
  #named_scope :published, :conditions => {:status => ['published', 'registration_open', 'registration_closed']}
  named_scope :latest, lambda { |count| {:limit => count, :order => 'created_at DESC'} }
  
  def to_param
    url
  end
  
  def location_address
    [location_address_county, location_address_municipality, location_address_settlement].compact.map(&:name).join(', ')
  end
  
  def published?
    ['published', 'registration_open', 'registration_closed'].include?(self.status)
  end
  
  private
  
  def set_defaults
    self.code = ActiveSupport::SecureRandom.base64(6).upcase
    self.status = 'new' if self.status.blank?
  end
end
