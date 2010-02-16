class User < ActiveRecord::Base
  
  acts_as_authentic
  model_stamper
  
  default_scope :conditions => {:deleted_at => nil}
  
  def name
    [firstname, lastname] * ' '
  end
end
