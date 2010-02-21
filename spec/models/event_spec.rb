require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :kind => "value for kind",
      :location_address_country_code => "value for location_address_country_code",
      :location_address_county_id => 1,
      :location_address_municipality_id => 1,
      :location_address_settlement_id => 1,
      :location_address_street => "value for location_address_street",
      :aim_description => "value for aim_description"
    }
  end

  it "should create a new instance given valid attributes" do
    Event.create!(@valid_attributes)
  end
end
