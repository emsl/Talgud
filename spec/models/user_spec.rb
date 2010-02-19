require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User, 'validations' do
  
  before(:each) do
    @valid_attributes = {
      :firstname => 'Foo', :lastname => 'Bar', :email => 'example@example.com',
      :password => 'abc', :password_confirmation => 'abc'
    }
  end
  
  it 'should require firstname, lastname and email' do
    User.with_options(:password => 'abc', :password_confirmation => 'abc') do |u|
      u.new(:firstname => 'Foo', :lastname => 'Bar', :email => 'example@example.com').should be_valid
      u.new(:firstname => 'Foo', :lastname => 'Bar').should_not be_valid
      u.new.should_not be_valid
    end
  end
  
  it 'should require password to be at least 3 characters long' do
    User.with_options(:firstname => 'Foo', :lastname => 'Bar', :email => 'example@example.com') do |u|
      u.new(:password => 'a', :password_confirmation => 'a').should_not be_valid
      u.new(:password => 'abcd', :password_confirmation => 'abce').should_not be_valid
      u.new(:password => 'abc', :password_confirmation => 'abc').should be_valid
    end
  end

  it 'should validate e-mail format' do
    User.new(@valid_attributes.merge(:email => 'invalid_email')).should have(1).error_on(:email)
  end
  
  it 'should validate if e-mail is unique' do
    User.create!(@valid_attributes)
    User.new(@valid_attributes).should have(2).errors_on(:email)
  end
end

describe User, 'activate!' do
  
  it 'should set user status to active' do
    user = Factory(:user_not_activated)
    user.should_not be_active
    user.activate! and user.reload
    user.should be_active
  end
end
