require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParticipationsController, 'create' do
  before(:each) do
    @event = Factory(:event)
    @ep = Factory.build(:event_participant)
  end
  
  it 'should create event participation record when submitted data is valid' do
    post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
    response.should redirect_to(event_path(@event))
  end
  
  it 'should send e-mail to all registered participants after successful registration' do
    Mailers::EventMailer.should_receive(:deliver_participant_notification)
    post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
  end
  
  it 'should send e-mail to event managers after successful registration' do
    Role.grant_role(Role::ROLE[:event_manager], Factory(:user), @event)
    Mailers::EventMailer.should_receive(:deliver_manager_participation_notification).twice
    post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
  end
  
  it 'should send e-mail to participant friends if their e-mails are supplied' do
    @ep.tellafriend_emails = 'a@example.com,b@example.com,c@example.com'
    Mailers::EventMailer.should_receive(:deliver_tell_friend_notification).exactly(3).times
    post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
  end
  
  it 'should show register screen when registration info is invalid' do
    @ep.firstname = nil
    @ep.lastname = nil
    post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
    response.should render_template(:new)
  end
end
