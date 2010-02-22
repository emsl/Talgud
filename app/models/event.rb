class Event < ActiveRecord::Base
  
  acts_as_scoped :account
  acts_as_url :name, :scope => :account_id, :only_when_blank => true
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  belongs_to :event_type
  belongs_to :manager, :class_name => 'User', :foreign_key => :manager_id
  belongs_to :location_address_county, :class_name => 'County', :foreign_key => :location_address_county_id
  belongs_to :location_address_municipality, :class_name => 'Municipality', :foreign_key => :location_address_municipality_id
  belongs_to :location_address_settlement, :class_name => 'Settlement', :foreign_key => :location_address_settlement_id
  
  before_validation_on_create :set_defaults
  
  validates_presence_of :name, :code, :url, :begins_at, :ends_at, :event_type, :manager, :status, :location_address_country_code, :location_address_county, :location_address_municipality
  
  named_scope :published, :conditions => {:status => 'created'}
  named_scope :latest, lambda { |count| {:limit => count, :order => 'created_at DESC'} }
  
  def to_param
    url
  end
  
  private
  
  def set_defaults
    self.code = ActiveSupport::SecureRandom.base64(6).upcase
    self.status = 'created'
  end
end
