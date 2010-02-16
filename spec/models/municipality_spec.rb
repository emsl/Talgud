require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Municipality do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :kind => "value for kind",
      :county_id => 1,
      :deleted_at => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    Municipality.create!(@valid_attributes)
  end
end
