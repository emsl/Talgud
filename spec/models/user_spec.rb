require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User, 'validations' do
  
  before(:each) do
    @valid_attributes = {
      :firstname => 'Foo', :lastname => 'Bar', :email => 'example@example.com',
      :password => 'abc', :password_confirmation => 'abc', :phone => '1234'
    }
  end
  
  it 'should require firstname, lastname and email' do
    User.with_options(:password => 'abc', :password_confirmation => 'abc', :phone => '1234') do |u|
      u.new(:firstname => 'Foo', :lastname => 'Bar', :email => 'example@example.com').should be_valid
      u.new(:firstname => 'Foo', :lastname => 'Bar').should_not be_valid
      u.new.should_not be_valid
    end
  end
  
  it 'should require password to be at least 3 characters long' do
    User.with_options(:firstname => 'Foo', :lastname => 'Bar', :email => 'example@example.com', :phone => '1234') do |u|
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

  it 'should validate minimum length phone' do
    user = Factory.build(:user, :phone => '12')
    user.should have(1).error_on(:phone)
  end

  it 'should validate maximum length phone' do
    user = Factory.build(:user, :phone => '1234567890123456789012345678901234567890')
    user.should have(1).error_on(:phone)
  end

  it 'should sanitaze phone' do
    user = Factory(:user, :phone => ' +372 (712 1490)')
    user.phone.should eql('+3727121490')
  end

  it 'should not validate blank phone' do
    user = Factory.build(:user, :phone => nil)
    user.should be_invalid
    user = Factory.build(:user, :phone => '')
    user.should be_invalid
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

describe User, 'role_symbols' do
  it 'should return no roles for unauthenticated user' do
    user = Factory(:user)
    user.class.stamper = nil
    user.role_symbols.should be_empty
  end

  it 'should return :user role for authenticated user' do
    user = Factory(:user)
    user.class.stamper = Factory(:user).id
    user.role_symbols.should include(:event_manager)
  end

  it 'should return :system_administrator role if granted' do
    role = Factory(:role_system_administrator)    
    role.user.role_symbols.should include(:system_administrator)
  end
end


describe User, 'reset_password!' do
  it 'should set new password for user' do
    user = Factory(:user)
    old_password = user.password
    user.reset_password!
    user.password.should_not eql(old_password)
  end
end
