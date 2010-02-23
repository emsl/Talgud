class Role < ActiveRecord::Base
  acts_as_scoped :account
  
  belongs_to :user
end
