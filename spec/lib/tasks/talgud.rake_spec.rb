require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'rake'

describe "talgud rake tasks" do
  
  before(:each) do
    @stdout = $stdout
    # Rake tasks generate standard output just a little bit. It's okay but we do not want to see it on screen.
    $stdout = StringIO.new
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/talgud"
    Rake::Task.define_task(:environment)
  end
  
  after(:each) do
    # Restore previous STDOUT
    $stdout = @stdout
  end
  
  describe "rake talgud:account:create" do
    before(:each) do
      @task_name = "talgud:account:create"
    end
    
    it "should have 'environment' as a prereq" do
      @rake[@task_name].prerequisites.should include("environment")
    end
    
    it "should create new account and user and grant account_manager role to that user" do
      account = Factory.build(:account)
      user = Factory.build(:user)
      Account.find_by_domain(account.domain).should be_nil
      User.find_by_email(user.email).should be_nil
      @rake[@task_name].invoke(account.name, account.domain, user.email, user.password)
      account = Account.find_by_domain(account.domain)
      account.should_not be_nil
      account.domain.should eql(account.domain)
      account.name.should eql(account.name)
      user = User.find_by_email(user.email)
      user.should_not be_nil
      user.active?.should be_true
      Role.has_role?(Role::ROLE[:account_manager], user, account).should be_true
    end

    it "should not fail on existing account and create new user and grant account_manager role to that user" do
      account = Factory(:account)
      user = Factory.build(:user)
      Account.find_by_domain(account.domain).should_not be_nil
      User.find_by_email(user.email).should be_nil
      @rake[@task_name].invoke(account.name, account.domain, user.email, user.password)
      user = User.find_by_email(user.email)
      user.should_not be_nil
      user.active?.should be_true
      Role.has_role?(Role::ROLE[:account_manager], user, account).should be_true
    end

    it "should activate existing user and grant account_manager role" do
      account = Factory(:account)
      user = Factory(:user, :status => User::STATUS[:created])
      Account.find_by_domain(account.domain).should_not be_nil
      User.find_by_email(user.email).should_not be_nil
      @rake[@task_name].invoke(account.name, account.domain, user.email, user.password)
      user = User.find_by_email(user.email)
      user.active?.should be_true
      Role.has_role?(Role::ROLE[:account_manager], user, account).should be_true
    end
  end
end
