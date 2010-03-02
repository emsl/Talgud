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

describe Event, 'start and end time' do
  it 'should return formatted time' do
    @event = Factory.build(:event)
    @event.begin_time = '9:09'
    @event.begin_time.should eql('9:09')
    @event.end_time = '21:12'
    @event.end_time.should eql('21:12')
  end
end

describe Event, 'start and end time changing' do
  it 'should update time but keep date intact' do
    @event = Factory.build(:event)
    @event.begin_time = '9:09'
    @event.begins_at.hour.should eql(9)
    @event.begins_at.min.should eql(9)
    
    @event.end_time = '21:12'
    @event.ends_at.hour.should eql(21)
    @event.ends_at.min.should eql(12)
  end
end

describe Event, 'event code generation' do
  it 'should generate event code' do
    @event = Factory(:event)
    @event.code.should_not be_nil
  end

  it 'should validate dublicate event code' do
    @event = Factory(:event)
    @event.code.should_not be_nil
    
    @event = Factory.build(:event, :code => @event.code)
    @event.should be_invalid
    @event.should have(1).error_on(:code)
  end
end

describe Event, 'regional_managers' do
  before(:each) do
    @regional_manager = Factory(:user)

    @county = Factory(:county)
    @municipality = Factory(:municipality)
    @settlement = Factory(:settlement)
    @event = Factory(:event, :location_address_settlement => @settlement, :location_address_municipality => @municipality, :location_address_county => @county)
  end

  it 'should give list of users associated with event location settlement if available' do
    Role.grant_role(Role::ROLE[:regional_manager], @regional_manager, @settlement)
    @event.regional_managers.should include(@regional_manager)
  end

  it 'should give list of users associated with event location municipality if available' do
    Role.grant_role(Role::ROLE[:regional_manager], @regional_manager, @municipality)
    @event.regional_managers.should include(@regional_manager)
  end

  it 'should give list of users associated with event location county if available' do
    Role.grant_role(Role::ROLE[:regional_manager], @regional_manager, @county)
    @event.regional_managers.should include(@regional_manager)
  end
end
