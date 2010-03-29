require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActionMailer::Base do
  
  describe 'smtp account rotation' do
    before(:each) do
      @user = Factory(:user)
      @event = Factory(:event)
      
      @acc1 = {:username => 'mail1@mail.com', :password => 'password1'}
      @acc2 = {:username => 'mail1@mail.com', :password => 'password1'}
      @acc3 = {:username => 'mail1@mail.com', :password => 'password1'}
      @accounts = [@acc1, @acc2, @acc3]
            
      Talgud.config.mailer.stub!(:smtp_accounts).and_return @accounts
    end
    
    it 'should rotate smtp_accounts' # do
     #      mail = Mailers::EventMailer.create_region_manager_notification(@user, @event, nil)
     #      ActionMailer::Base.new.smtp_settings[:username].should eql(@acc1[:username])
     #      ActionMailer::Base.new.smtp_settings[:username].should eql(@acc2[:username])
     #      ActionMailer::Base.new.smtp_settings[:username].should eql(@acc3[:username])
     #      ActionMailer::Base.new.smtp_settings[:username].should eql(@acc1[:username])
     #    end
  end
end