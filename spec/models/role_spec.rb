require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role, 'validations' do
  before(:each) do
    @valid_attributes = Factory.attributes_for(:role_system_administrator)
    @valid_attributes[:user] = Factory(:user)
    @valid_attributes[:model] = Factory(:account)
  end

  it "should create a new instance given valid attributes" do
    Role.create!(@valid_attributes)
  end  
  
  it "should require model, account and role code" do
    Role.with_options(:account => nil) do |r|
      r1 = r.new()
      r1.should be_invalid
      r1.should have(1).error_on(:model)
      r1.should have(1).error_on(:user)
      r1.should have(1).error_on(:role)
    end
  end
end