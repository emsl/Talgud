require 'spec_helper'

describe EventParticipation do
  before(:each) do
    @valid_attributes = {
      :firstname => "value for firstname",
      :lastname => "value for lastname",
      :email => "value for email",
      :notes => "value for notes",
      :invite_emails => "value for invite_emails",
      :parent_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    EventParticipation.create!(@valid_attributes)
  end
end
