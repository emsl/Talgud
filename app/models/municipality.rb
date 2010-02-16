class Municipality < ActiveRecord::Base
  
  belongs_to :county
  has_many :settlements
end
