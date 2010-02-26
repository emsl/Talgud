require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PasswordRemindersController, 'create' do

  it 'should let user model generate new password and redirect to login screen' do
    user = Factory(:user)
    Mailers::UserMailer.should_receive(:deliver_password_reminder)
    
    post :create, {:email => user.email}
    response.should redirect_to(login_path)
    flash[:notice].should_not be_blank
  end
  
  it 'should set a warning message and redirect to login screen when user is not found' do
    user = Factory(:user)
    Mailers::UserMailer.should_not_receive(:deliver_password_reminder)
    
    post :create, {:email => "not_#{user.email}"}
    response.should redirect_to(login_path)
    flash[:error].should_not be_blank
  end

end
