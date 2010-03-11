require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParticipationsController, 'create' do
  it 'should create event participation record when submitted data is valid'
  
  it 'should send e-mail to all registered participants after successful registration'
  
  it 'should send e-mail to event managers after successful registration'
  
  it 'should send e-mail to participant friends if their e-mails are supplied'
  
  it 'should show register screen when registration info is invalid'
end
