require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController do

  #Delete these examples and add some real ones
  it "should use EventsController" do
    controller.should be_an_instance_of(EventsController)
  end


  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end
end
