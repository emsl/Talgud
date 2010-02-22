class Event < ActiveRecord::Base
  
  acts_as_scoped :account
  acts_as_url :name, :scope => :account_id, :only_when_blank => true
  
  belongs_to :event_type
  belongs_to :manager, :class_name => 'User', :foreign_key => :manager_id
  
  before_validation_on_create :set_defaults
  
  validates_presence_of :name, :code, :url, :begins_at, :ends_at, :event_type, :manager, :status, :location_address_country_code
  
  def to_param
    url
  end
  
  private
  
  def set_defaults
    self.code = ActiveSupport::SecureRandom.base64(6).upcase
    self.status = 'created'
  end
end
