class CodeSequence < ActiveRecord::Base
  
  acts_as_scoped :account
  
  validates_presence_of :code, :sequence, :account
  validates_uniqueness_of :sequence, :scope => :code
  
  def before_save    
    self.value = 1 if new_record?
  end
  
  def self.next_value(obj, pattern = Time.now.strftime('%y%m%d'))
    last_sequence = CodeSequence.first(:conditions => {:code => obj.class.name, :sequence => pattern}, :lock => true)
    if last_sequence
      last_sequence.value = last_sequence.value + 1
      last_sequence.save!
      last_sequence
    else
      CodeSequence.create!(:code => obj.class.name, :sequence => pattern)
    end
  end
  
  def label
    [self.sequence, self.value].join('')
  end
end
