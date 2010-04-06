require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event, 'validations' do
  it 'should validate that begin date is before end date' do
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 0.days.ago).should be_valid
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 2.days.ago).should be_invalid
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 1.days.ago).should be_valid
  end
  
  it 'should validate that begin time is before end time' do
    time = 1.day.from_now
    Factory.build(:event, :begins_at => time, :ends_at => time + 1.minute).should be_valid
    # TODO: mutating start and end time should be possible by simply declaring them as create attributes
    f = Factory.build(:event, :begins_at => time, :ends_at => time)
    f.begin_time = '11:00'
    f.end_time = '10:00'
    f.should be_invalid

    # TODO: enable for next iteration
    # f.begin_time = '10:00'
    # f.end_time = '10:00'
    # f.should be_invalid
  end

  it 'should validate that number of participants is a positive number' do
    Factory(:event, :max_participants => 1).should be_valid
    Factory.build(:event, :max_participants => 0).should be_invalid
    Factory.build(:event, :max_participants => -1).should be_invalid
  end
  
  it 'should validate municipality in county' do
    event = Factory.build(:event)
    event.location_address_municipality = Factory(:municipality)
    event.should be_invalid
  end
  
  it 'should validate settlement in municipality' do
    event = Factory.build(:event)
    event.location_address_settlement = Factory(:settlement)
    event.should be_invalid
  end

  it 'should validate settlement and municipality' do
    event = Factory.build(:event)
    event.location_address_settlement = nil
    event.should be_valid
  end
  
end

describe Event, 'create' do
  it 'should associate event manager role to creator of the event' do
    @event = Factory(:event)
    @event.roles.should_not be_nil
    @event.roles.collect(&:role).should include(Role::ROLE[:event_manager])
  end
end

describe Event, 'run_state_jobs' do
  it 'should change state to registration_closed after vacanies' do
    @event1 = Factory(:event, :status => Event::STATUS[:registration_open], :current_participants => 12, :max_participants => 10)
    @event2 = Factory(:event, :status => Event::STATUS[:registration_open], :current_participants => 20, :max_participants => 20)
    
    Event.run_state_jobs
    @event1.reload
    @event2.reload

    @event1.status.should eql(Event::STATUS[:registration_closed])
    @event2.status.should eql(Event::STATUS[:registration_closed])
  end
  
  it 'should not change state to registration_closed if registration ends at date is in the future' do
    @event1 = Factory(:event, :status => Event::STATUS[:registration_open], :current_participants => 10, :max_participants => 100)
    @event2 = Factory(:event, :status => Event::STATUS[:registration_open], :current_participants => 9, :max_participants => 10)
    
    Event.run_state_jobs
    @event1.reload
    @event2.reload

    @event1.status.should eql(Event::STATUS[:registration_open])
    @event2.status.should eql(Event::STATUS[:registration_open])    
  end
  
  it 'should change state to took_place after 2 days from ends_at day' do
    @event1 = Factory(:event, :status => Event::STATUS[:registration_closed], :begins_at => 5.days.ago, :ends_at => 4.days.ago)
    @event2 = Factory(:event, :status => Event::STATUS[:registration_closed], :begins_at => 4.days.ago, :ends_at => 3.days.ago)
    
    Event.run_state_jobs
    @event1.reload
    @event2.reload

    @event1.status.should eql(Event::STATUS[:took_place])
    @event2.status.should eql(Event::STATUS[:took_place])    
  end
  
  it 'should not change state to took_place after 1 day from ends_at day' do
    @event = Factory(:event, :status => Event::STATUS[:registration_closed], :begins_at => 5.days.ago, :ends_at => 1.day.ago)
    Event.run_state_jobs
    @event.reload
    @event.status.should eql(Event::STATUS[:registration_closed])    
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

describe Event, 'vacancies' do
  it 'should calculate vacancies' do
    @event = Factory.build(:event, :max_participants => 10, :current_participants => 2)
    @event.vacancies.should eql(8)
  end

  it 'should return 0 vacancies' do
    @event = Factory.build(:event, :max_participants => 10, :current_participants => 11)
    @event.vacancies.should eql(0)
  end
end

describe Event, 'can_register?' do
  it 'should return true while there are vacancies and status is registration_open' do
    @event = Factory.build(:event, :max_participants => 10, :current_participants => 2, :status => Event::STATUS[:registration_open])
    @event.can_register?.should be_true
  end

  it 'should return false while there are vacancies but status is different from registration_open' do
    @event = Factory.build(:event, :max_participants => 10, :current_participants => 2, :status => Event::STATUS[:registration_closed])
    @event.can_register?.should be_false
  end

  it 'should return false while there are no vacancies but status is registration_open' do
    @event = Factory.build(:event, :max_participants => 10, :current_participants => 10, :status => Event::STATUS[:registration_open])
    @event.can_register?.should be_false
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
    
    @event2 = Factory.build(:event, :code => @event.code)
    @event2.stub!(:code).and_return @event.code    
    
    @event2.should be_invalid
    @event2.should have(1).error_on(:code)
  end

  it 'should not miss event code sequence on invalid event' do
    @event = Factory.build(:event, :name => nil)
    @event.should be_invalid
    @event.code.length.should eql(24)
    @event.name = '1234'
    @event.should be_valid
    @event.save!    
    @event.code.length.should eql(7)
  end

  it 'should not generate new event code on save' do
    @event = Factory(:event)
    code = @event.code
    @event.name = '1234'
    @event.save!
    @event.code.should eql(code)
  end
end

describe Event, 'regional_managers' do
  before(:each) do
    @regional_manager = Factory(:user)

    @settlement = Factory(:settlement)
    @municipality = @settlement.municipality
    @county = @municipality.county
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


describe Event, 'named scopes' do
  it 'should return latest events' do
    e1 = Factory(:event)
    e2 = Factory(:event)
    e3 = Factory(:event)
    Event.latest(2).should include(e3, e2)
    Event.latest(2).should_not include(e1)
  end

  it 'should return published events' do
    e1 = Factory(:event, :status => Event::STATUS[:published])
    e2 = Factory(:event, :status => Event::STATUS[:registration_open])
    e3 = Factory(:event, :status => Event::STATUS[:registration_closed])
    e4 = Factory(:event, :status => Event::STATUS[:closed])
    e5 = Factory(:event, :status => Event::STATUS[:new])
    Event.published.should include(e1, e2, e3)
    Event.published.should_not include(e4, e5)
  end
end