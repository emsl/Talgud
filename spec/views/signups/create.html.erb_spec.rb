require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Successful signup form" do
  
  before(:each) do
    render 'signups/create'
  end

  it 'should display that account has been created and validation instructions have been sent to email'
  
end
