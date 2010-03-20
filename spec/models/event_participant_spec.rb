require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventParticipant, 'validations' do
  it "should validate presence of first and lastname" do
    @event_participant = Factory.build(:event_participant, :firstname => nil, :lastname => nil)
    @event_participant.should be_invalid
    @event_participant.should have(1).error_on(:firstname)
    @event_participant.should have(1).error_on(:lastname)
  end

  it "should validate presence of email and phone on parent record" do
    @event_participant = Factory.build(:event_participant, :phone => nil, :email => nil)
    @event_participant.should be_invalid
    @event_participant.should have(1).error_on(:phone)
    @event_participant.should have(1).error_on(:email)
  end

  it "should validate presence of email and phone on child record" do
    @event_participant = Factory.build(:event_participant, :phone => nil, :email => nil, :event_participant => Factory(:event_participant))
    @event_participant.should be_valid
  end
end

describe EventParticipant, 'parent' do
  it "should return true on parent record" do
    @event_participant = Factory(:event_participant, :event_participant => nil)
    @event_participant.parent?.should be_true
  end

  it "should return false on child record" do
    @event_participant = Factory(:event_participant, :event_participant => Factory(:event_participant))
    @event_participant.parent?.should be_false
  end
end

describe EventParticipant, 'create' do
  it "should update event current participiants count after save" do
    @event = Factory(:event)
    @event.should be_valid

    @event_participant = Factory(:event_participant, :event => @event)
    @event_participant.should be_valid
    @event.current_participants.should eql(1)

    @event_participant = Factory(:event_participant, :event => @event)
    @event.current_participants.should eql(2)

    @event_participant = Factory.build(:event_participant, :event => @event)
    @event.current_participants.should eql(2)
    @event_participant.save!
    @event.current_participants.should eql(3)
  end
end

describe EventParticipant, 'recommend_emails' do
  before(:each) do
    @ep = Factory(:event_participant)
  end

  it 'should return array of emails stored in tellafriend_emails field' do
    @ep.tellafriend_emails = 'test@example.com'
    @ep.recommend_emails.should eql(['test@example.com'])

    @ep.tellafriend_emails = 'test@example.com,test@example.com'
    @ep.recommend_emails.should eql(['test@example.com'])

    @ep.tellafriend_emails = 'test1@example.com,test2@example.com'
    @ep.recommend_emails.should include('test1@example.com')
    @ep.recommend_emails.should include('test2@example.com')

    @ep.tellafriend_emails = 'test1@example.com, test2@example.com'
    @ep.recommend_emails.should include('test1@example.com')
    @ep.recommend_emails.should include('test2@example.com')

    @ep.tellafriend_emails = 'not_an_email'
    @ep.recommend_emails.should be_empty

    @ep.tellafriend_emails = 'test@example.com, not_an_email'
    @ep.recommend_emails.should eql(['test@example.com'])
  end
  
  it 'should return empty array on nil' do
    @ep.tellafriend_emails = nil
    @ep.recommend_emails.should be_empty
  end
end

describe EventParticipant, 'participant_name' do
  it 'should glue firstname and lastname together' do
    @event_participant = Factory(:event_participant, :firstname => 'John', :lastname => 'Smith')
    @event_participant.participant_name.should eql('John Smith')
  end
end

describe EventParticipant, 'participant counting' do
  it 'should update number of participants associated with event after new participant has been registered' do
    event = Factory(:event, :max_participants => 10)
    lambda {
      2.times { |i| Factory(:event_participant, :event => event) }
    }.should change(event, :current_participants).by(2)
  end
end
