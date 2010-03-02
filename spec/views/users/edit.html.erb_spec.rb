require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/edit" do
  before(:each) do
    @user = Factory(:user)
    assigns[:user] = @user
    render 'users/edit'
  end

  it 'should render form with user firstname, lastname, phone and password fields' do
    response.should have_tag('form[action=?]', user_path(@user)) do
      with_tag('input[name=?]', 'user[firstname]')
      with_tag('input[name=?]', 'user[lastname]')
      with_tag('input[name=?]', 'user[phone]')
      with_tag('input[name=?]', 'user[password]')
      with_tag('input[name=?]', 'user[password_confirmation]')
      with_tag('input[type=submit]')
    end
  end
end
