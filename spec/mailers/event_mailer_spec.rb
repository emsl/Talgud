require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mailers::EventMailer, :type => :view do
  
  describe 'region_manager_notification' do
    before(:each) do
      @user = Factory(:user)
      @event = Factory(:event)
      @url = admin_event_url(@event.id)
      @mail = Mailers::EventMailer.create_region_manager_notification(@user, @event, @url)
    end
    
    it 'should contain information about registered event and send link to event admin view' do
      @mail.body.should include(@event.name)
      @mail.body.should include(@event.event_type.name)
      @mail.body.should include(@event.location_address)
      @mail.body.should include(@event.meta_aim_description)
      @mail.body.should include(@event.meta_job_description)
      @mail.body.should include(@event.max_participants)
      @mail.body.should include(I18n.l(@event.begins_at))
      @mail.body.should include(@event.meta_bring_with_you)
      @mail.body.should include(@event.meta_provided_for_participiants)
      @mail.body.should include(@event.meta_subject_info)
      @mail.body.should include(@event.manager.name)
      @mail.body.should include(@event.manager.email)
      @mail.body.should include(@event.gathering_location)
      @mail.body.should include(@event.notes)
      @mail.body.should include(@url)
    end
  end
  
  describe 'participant_notification' do
    before(:each) do
      @event_participant = Factory(:event_participant)
      @edit_url = event_participation_url(@event_participant.event, @event_participant)
      @event_url = event_url(@event_participant.event)
      @mail = Mailers::EventMailer.create_participant_notification(@event_participant, @event_url, @edit_url)
    end
    
    it 'should contain event info and link to edit participation info' do
      @mail.body.should include(@event_participant.event.name)
      @mail.body.should include(@event_participant.participant_name)
      @mail.body.should include(@event_participant.email)
      @mail.body.should include(@event_participant.phone)
      @mail.body.should include(@event_url)
      @mail.body.should include(@edit_url)
    end
  end
  
  describe 'invited_participant_notification' do
    before(:each) do
      @event_participant = Factory(:event_participant, :event_participant => Factory(:event_participant))
      @edit_url = event_participation_url(@event_participant.event, @event_participant)
      @event_url = event_url(@event_participant.event)
      @mail = Mailers::EventMailer.create_invite_participant_notification(@event_participant, @event_url, @edit_url)
    end
    
    it 'should contain parent participant name and event information' do
      @mail.body.should include(@event_participant.event_participant.participant_name)
      @mail.body.should include(@event_participant.event.name)
      @mail.body.should include(@event_url)
      @mail.body.should include(@edit_url)
    end
  end
  
  describe 'manager_participation_notification' do
    before(:each) do
      @event_participant = Factory(:event_participant)
      @event_participations_url = event_participations_url(@event_participant.event)
      @event_manager = Factory(:user)
      @mail = Mailers::EventMailer.create_manager_participation_notification(@event_manager, @event_participant, @event_participations_url)
    end
    
    it 'should contain event and participant infor and link to participants page' do
      @mail.subject.should include(@event_participant.event.name)
      @mail.subject.should include(@event_participant.participant_name)
      @mail.body.should include(@event_participant.participant_name)
      @mail.body.should include(@event_participant.email)
      @mail.body.should include(@event_participant.phone)
      @mail.body.should include(@event_participations_url)
    end
  end
  
  describe 'tell_friend_notification' do
    before(:each) do
      @event_participant = Factory(:event_participant)
      @event_url = event_url(@event_participant.event)
      @mail = Mailers::EventMailer.create_tell_friend_notification('test@example.com', @event_participant, @event_url)
    end
    
    it 'should countain user name, event name and link to event page' do
      @mail.subject.should include(@event_participant.participant_name)
      @mail.body.should include(@event_participant.participant_name)
      @mail.body.should include(@event_participant.event.name)
      @mail.body.should include(@event_url)
    end
  end
end
