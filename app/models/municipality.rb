class Municipality < ActiveRecord::Base
  
  acts_as_scoped :account
  
  KIND = [:linn, :vald]
  
  belongs_to :county
  has_many :settlements
  
  validates_presence_of :name, :kind, :county
end
