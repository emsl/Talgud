class UserRoles < ActiveRecord::Base
  
  acts_as_scoped :account
  
  belongs_to :user
  belongs_to :role
end
