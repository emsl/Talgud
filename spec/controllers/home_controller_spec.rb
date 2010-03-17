require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do
  it "should set default language if language is not set" do
    get :index, {:language => nil}
    I18n.locale.should eql(:et)
  end
  
  it "should set default language on invalid language" do
    get :index, {:language => :es}
    I18n.locale.should eql(:et)    
  end
  
  it "should change language on valid language" do
    get :index, {:language => :ru}
    I18n.locale.should eql(:ru)
  end

  it "should set default language on session hack" do
    session[:language] = :es
    get :index
    I18n.locale.should eql(:et)
  end
end
