require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SignupsController, 'index' do
  it 'should redirect to signup screen' do
    get :index
    response.should redirect_to(signup_path)
  end
end

describe SignupsController, 'new' do
  it 'should assign new user record to view' do
    get :new
    assigns[:user].should_not be_nil
    assigns[:user].should be_new_record
  end
end

describe SignupsController, 'create' do
  it 'should create new user record if it is valid and render validation notify screen' do
    User.should_receive(:new).and_return(mock_model(User, :valid? => true, :save_without_session_maintenance => true, :perishable_token => 'abc'))
    Mailers::UserMailer.should_receive(:deliver_activation_instructions)
    post :create
    response.should render_template(:create)
  end
  
  it 'should send activation message to user after successful signup' do
    User.should_receive(:new).and_return(mock_model(User, :valid? => true, :save_without_session_maintenance => true, :perishable_token => 'abc'))
    Mailers::UserMailer.should_receive(:deliver_activation_instructions)
    post :create
  end
  
  it 'should not create new user record and render signup screen if it is not valid' do
    User.should_receive(:new).and_return(mock_model(User, :valid? => false))
    post :create
    response.should render_template(:new)
  end
end

describe SignupsController, 'activate' do
  it 'should activate user, create session and redirect to event create screen when user is not yet activated' do
    user = Factory(:user_not_activated)
    get :activate, {:activation_code => user.perishable_token}
    response.should redirect_to(new_event_path)
  end
  
  it 'should redirect to login screen when user has already been activated' do
    user = Factory(:user, :perishable_token => 'perishable_token')
    get :activate, {:activation_code => user.perishable_token}
    response.should redirect_to(login_path)
  end
  
  it 'should redirect to signup screen when activation code is invalid' do
    user = Factory(:user, :perishable_token => 'perishable_token')
    get :activate, {:activation_code => "not_#{user.perishable_token}"}
    response.should redirect_to(signup_path)
  end
end
