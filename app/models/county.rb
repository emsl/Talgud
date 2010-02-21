class County < ActiveRecord::Base
  
  acts_as_scoped :account
  
  has_many :municipalities
end
