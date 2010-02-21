class Municipality < ActiveRecord::Base
  
  acts_as_scoped :account
  
  belongs_to :county
  has_many :settlements
end
