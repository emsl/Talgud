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
end
