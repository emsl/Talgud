class County < ActiveRecord::Base
  
  has_many :municipalities
end
