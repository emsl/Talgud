class EventType < ActiveRecord::Base
  
  acts_as_scoped :account
  
  has_many :events
  
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  
  default_scope :conditions => {:deleted_at => nil}
  named_scope :sorted, :order => {:name => ' ASC'}
  
  def name
    I18n.translate("formtastic.labels.event_type.event_types.#{self.attributes['name'].downcase}", :default => self.attributes['name'])
  end
end