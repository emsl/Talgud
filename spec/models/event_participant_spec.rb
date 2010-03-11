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
