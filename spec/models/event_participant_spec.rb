require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventParticipant, 'validations' do
  it "should validate presence of first and lastname" do
    ep = Factory.build(:event_participant, :firstname => nil, :lastname => nil)
    ep.should be_invalid
    ep.should have(1).error_on(:firstname)
    ep.should have(1).error_on(:lastname)
  end

  it "should validate presence of email and phone on parent record" do
    ep = Factory.build(:event_participant, :phone => nil, :email => nil)
    ep.should be_invalid
    ep.should have(1).error_on(:phone)
    ep.should have(1).errors_on(:email)
  end

  it "should validate presence of email and phone on child record" do
    ep = Factory.build(:event_participant, :phone => nil, :email => nil, :event_participant => Factory(:event_participant))
    ep.should be_valid
  end
  
  it 'should validate format of email' do
    ep = Factory.build(:event_participant, :email => 'invalid_email')
    ep.should have(1).error_on(:email)
  end
  
  it 'should mark event as spam when links are present in tell-friend or notes emails' do
    [:notes, :tellafriend_emails].each do |attrib|
      ep = Factory.build(:event_participant, attrib => '<a href="http://rexmztwamxbd.com/">rexmztwamxbd</a>')
      ep.should have(1).error_on(attrib)
      ep = Factory.build(:event_participant, attrib => '[url=http://envrnweyvdqo.com/]envrnweyvdqo[/url]')
      ep.should have(1).error_on(attrib)
      ep = Factory.build(:event_participant, attrib => '[link=http://envrnweyvdqo.com/]envrnweyvdqo[/link]')
      ep.should have(1).error_on(attrib)
    end
  end
end

describe EventParticipant, 'parent' do
  it "should return true on parent record" do
    ep = Factory(:event_participant, :event_participant => nil)
    ep.parent?.should be_true
  end

  it "should return false on child record" do
    ep = Factory(:event_participant, :event_participant => Factory(:event_participant))
    ep.parent?.should be_false
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
    ep = Factory(:event_participant, :firstname => 'John', :lastname => 'Smith')
    ep.participant_name.should eql('John Smith')
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
