class User < ActiveRecord::Base
  
  # Authlogic specific intitalizer
  acts_as_authentic do |a|
    a.validates_length_of_password_field_options = {:on => :create, :minimum => 3}
    a.validates_length_of_password_confirmation_field_options = {:on => :create, :minimum => 3}
  end
  
  # Marks that this model is a creator and updater for other models.
  model_stamper
  
  # Let only certain fields to be set through forms
  attr_accessible :firstname, :lastname, :email, :password, :password_confirmation
  
  default_scope :conditions => {:deleted_at => nil}
  
  # Before validation, set default status for user. Otherwise this record does not validate.
  before_validation_on_create :set_default_status
  
  validates_presence_of :firstname, :lastname, :email
  validates_uniqueness_of :email
  
  # Register all available statuses for this user. Setting status for user record should be only done by using the
  # constants defined here.
  STATUS = {:created => 'created', :active => 'active'}
  
  # Returns full name for given user.
  def name
    [firstname, lastname] * ' '
  end
  
  # Authlogic "magic" to check whether user is activated and therefore is allowed to login.
  def active?
    status == STATUS[:active]
  end
  
  def confirmed?
    status == STATUS[:active]
  end
  
  # Activates user by bringing it from created status to active status.
  def activate!
    update_attribute(:status, STATUS[:active])
  end
  
  private
  
  def set_default_status
    write_attribute(:status, STATUS[:created]) if read_attribute(:status).blank?
  end
end
