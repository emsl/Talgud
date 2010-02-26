require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mailers::UserMailer, :type => :view do
  
  describe 'activation_instructions' do
    
    before(:each) do
      @user = Factory(:user)
      @url = activate_url(:activation_code => 'foobar')
      @mail = Mailers::UserMailer.create_activation_instructions(@user, @url)
    end
    
    it 'should contain activation link inside message' do
      @mail.body.should include(@url)
    end
  end
  
  describe 'password_reminder' do
    
    before(:each) do
      @user = Factory(:user)
      @password = @user.reset_password!
      @login_url = login_url
      @mail = Mailers::UserMailer.create_password_reminder(@user, @password, @login_url)
    end
    
    it 'should contain new password and link to login screen inside message' do
      @mail.body.should include(@login_url)
      @mail.body.should include(@password)
    end
  end
end
