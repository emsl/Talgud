class Language < ActiveRecord::Base  
  acts_as_scoped :account
  
  validates_presence_of :name, :code
  validates_uniqueness_of :code, :case_sensitive => false  
end
