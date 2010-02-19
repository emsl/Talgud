require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Login form" do
  
  before(:each) do
    assigns[:user_session] = mock(UserSession, :email => 'email', :password => 'password', :errors => [])
    
    render 'user_sessions/new'
  end

  # it 'should display a form with email and password field' do
  #   response.should have_tag('form[action=?]', user_sessions_path) do
  #     with_tag('input[name=?]', 'user_session[email]')
  #     with_tag('input[name=?]', 'user_session[password]')
  #     with_tag('input[type=submit]')
  #   end
  # end
  
  it 'should display a form with password reminder fields' do
    response.should have_tag('form[action=?]', password_reminders_path) do
      with_tag('input[name=?]', 'email')
      with_tag('input[type=submit]')
    end
  end
end
