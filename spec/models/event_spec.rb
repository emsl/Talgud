require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event, 'validations' do
  it 'should validate that begin date is before end date' do
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 0.days.ago).should be_valid
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 2.days.ago).should be_invalid
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 1.days.ago).should be_valid
  end
  
  it 'should validate that number of participants is a positive number' do
    Factory(:event, :max_participants => 1).should be_valid
    Factory.build(:event, :max_participants => 0).should be_invalid
    Factory.build(:event, :max_participants => -1).should be_invalid
  end  
end

describe Event, 'create' do
  it 'should associate event manager role to creator of the event' do
    @event = Factory(:event)
    @event.roles.should_not be_nil
    @event.roles.collect(&:role).should include(Role::ROLE[:event_manager])
  end
end
