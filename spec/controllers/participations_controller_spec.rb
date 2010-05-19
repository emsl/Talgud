require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParticipationsController do
  describe 'new' do
    it 'should redirect to events path if there are no vacancies' do
      event = Factory(:event, :max_participants => 1)
      ep = Factory(:event_participant, :event => event)
      
      get :new, {:event_id => event.url}
      response.should redirect_to(event_path(event))
    end

    it 'should redirect to events path if registration is not opened' do
      event = Factory(:event, :max_participants => 10, :status => Event::STATUS[:published])
      ep = Factory(:event_participant, :event => event)
      
      get :new, {:event_id => event.url}
      response.should redirect_to(event_path(event))
    end
    
    it 'should render new registration form' do
      event = Factory(:event, :max_participants => 10, :status => Event::STATUS[:registration_open], 
        :registration_begins_at => Time.now - 1.minute, :registration_ends_at => 1.days.from_now)
      get :new, {:event_id => event.url}
      response.should be_success
    end    
  end
  
  describe 'create' do
    before(:each) do
      @event = Factory(:event)
      Role.grant_role(Role::ROLE[:event_manager], @event.manager, @event)
      @ep = Factory.build(:event_participant)
    end

    it 'should register more participants than maximum if there are vacancies' do
      event = Factory(:event)
      eps = Array.new(10) { |i| Factory.build(:event_participant, :event => event) }      
    end

    it 'should create event participation record when submitted data is valid' do
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
      response.should redirect_to(confirmation_event_participation_path(@event, UrlStore.encode(assigns[:event_participant].id)))
    end

    it 'should send e-mail to registrant after successful registration' do
      Mailers::EventMailer.should_receive(:deliver_participant_notification)
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes}
    end
    
    it 'should send e-mail to invited participants after successful registration' do
      Mailers::EventMailer.should_receive(:deliver_invite_participant_notification).twice
      children = {0 => Factory.build(:event_participant).attributes, 1 => Factory.build(:event_participant).attributes}
      post :create, {:event_id => @event.url, :event_participant => @ep.attributes.merge(:children_attributes => children)}
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
  
  describe 'edit' do
    before(:each) do
      @ep = Factory(:event_participant)
    end
        
    it 'should not accesible by public user' do
      EventParticipant.should_not_receive(:find)
      get :edit, {:event_id => @ep.event.url, :id => @ep.id}
      assigns[:event_participant].should be_nil
    end
  end

  describe 'editing participation from encoded url' do
    it 'should load participation when encoded url is valid' do
      ep = Factory(:event_participant)

      get :show, {:event_id => ep.event.url, :id => UrlStore.encode(ep.id)}
      response.should be_success
      response.should render_template(:show)
      assigns[:event_participant].should eql(ep)
    end

    it 'should redirect to participation show when encoded url is valid' do
      ep = Factory(:event_participant)
      id = UrlStore.encode(ep.id)
      get :redirect, {:id => id}
      response.should redirect_to(event_participation_path(ep.event, id))
    end

    it 'should redirect to event view when encoded url invalid' do
      ep = Factory(:event_participant)

      get :show, {:event_id => ep.event.url, :id => ep.id}
      response.should redirect_to(event_path(ep.event))
    end
  end
  
  describe 'updating participation from encoded url' do
    before(:each) do
      @event = Factory(:event)
      @ep = Factory(:event_participant, :children => [Factory(:event_participant), Factory(:event_participant)])
    end
    
    it 'should send e-mail to freshly invited participants after successful save' do
      Mailers::EventMailer.should_receive(:deliver_invite_participant_notification).twice

      children = {0 => Factory.build(:event_participant).attributes, 1 => Factory.build(:event_participant).attributes}
      put :update, {:event_id => @event.url, :id => UrlStore.encode(@ep.id), :event_participant => @ep.attributes.merge(:children_attributes => children)}
      
      response.should redirect_to(event_path(@event.url))
    end
  end
end
