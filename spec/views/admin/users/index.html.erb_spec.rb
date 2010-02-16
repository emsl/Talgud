require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/index" do
  
  before(:each) do
    assigns[:users] = []
    
    render 'admin/users/index'
  end

  it 'should display a list of users in system'
end
