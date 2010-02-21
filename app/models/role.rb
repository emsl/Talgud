class Role < ActiveRecord::Base
  
  acts_as_scoped :account
end
