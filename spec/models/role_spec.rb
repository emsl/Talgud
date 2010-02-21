require 'spec_helper'

describe Role do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :code => "value for code",
      :user_id => 1,
      :account_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Role.create!(@valid_attributes)
  end
end
