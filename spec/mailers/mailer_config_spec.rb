require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActionMailer::Base do
  
  describe 'smtp account rotation' do
    before(:each) do
      @acc1 = {:username => 'mail1@mail.com', :password => 'password1'}
      @acc2 = {:username => 'mail1@mail.com', :password => 'password1'}
      @acc3 = {:username => 'mail1@mail.com', :password => 'password1'}
      @accounts = [@acc1, @acc2, @acc3]
            
      Talgud.config.mailer.stub!(:smtp_accounts).and_return @accounts
    end
    
    it 'should rotate smtp_accounts' do
      ActionMailer::Base.smtp_settings[:username].should eql(@acc1[:username])
      ActionMailer::Base.smtp_settings[:username].should eql(@acc2[:username])
      ActionMailer::Base.smtp_settings[:username].should eql(@acc3[:username])
      ActionMailer::Base.smtp_settings[:username].should eql(@acc1[:username])
    end
  end
end