class Settlement < ActiveRecord::Base
  
  acts_as_scoped :account

  KIND = [:alevik, :alev, :kyla, :linnaosa, :vallasisene_linn]
  
  belongs_to :municipality
  
  validates_presence_of :name, :kind, :municipality
  
  default_scope :conditions => {:deleted_at => nil}
end
