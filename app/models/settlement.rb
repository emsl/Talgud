class Settlement < ActiveRecord::Base
  
  acts_as_scoped :account
  
  belongs_to :municipality
end
