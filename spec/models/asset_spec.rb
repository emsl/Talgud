require 'spec_helper'

describe Asset do
  before(:each) do
    @valid_attributes = {
      :attachment_file_name => "value for attachment_file_name"
    }
  end

  it "should create a new instance given valid attributes" do
    Asset.create!(@valid_attributes)
  end
end
