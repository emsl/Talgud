require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Signup form" do
  
  before(:each) do
    assigns[:user] = User.new
    
    render 'signups/new'
  end

  it 'should display a form with firstname, lastname, email and password fields to sign up' do
    response.should have_tag('form[action=?]', signups_path) do
      with_tag('input[name=?]', 'signup[firstname]')
      with_tag('input[name=?]', 'signup[lastname]')
      with_tag('input[name=?]', 'signup[email]')
      with_tag('input[name=?]', 'signup[password]')
      with_tag('input[name=?]', 'signup[password_confirmation]')
      with_tag('input[type=submit]')
    end
  end
end
