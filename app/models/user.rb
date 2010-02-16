class User < ActiveRecord::Base
  
  acts_as_authentic
  
  default_scope :conditions => {:deleted_at => nil}
  
  def name
    [firstname, lastname] * ' '
  end
end
