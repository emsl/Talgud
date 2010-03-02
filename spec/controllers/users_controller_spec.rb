require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do

  describe 'edit' do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    it 'should not be available for public' do
      get :edit, {:id => @user.id}
      response.should redirect_to(root_path)
    end
    
    context 'for authenticated users' do
      before(:each) do
        activate_authlogic and UserSession.create(@user)
      end
    
      it 'should only be accessible for current user' do
        get :edit, {:id => @user.id}
        response.should be_success
        response.should render_template(:edit)
      end
      
      it 'should not let edit other users' do
        another_user = Factory(:user)
        get :edit, {:id => another_user.id}
        response.should redirect_to(root_path)
      end
    end
  end
  
  describe 'update' do
    before(:each) do
      @user = Factory(:user)
    end
    
    it 'should not be available for public' do
      post :update, {:id => @user.id, :user => @user.attributes}
      response.should redirect_to(root_path)
    end
    
    context 'for authenticated users' do
      before(:each) do
        activate_authlogic and UserSession.create(@user)
      end
      
      it 'should only be accessible for current user' do
        post :update, {:id => @user.id, :user => @user.attributes}
        response.should redirect_to(edit_user_path(@user))
      end
      
      it 'should not let edit other users' do
        another_user = Factory(:user)
        post :update, {:id => another_user.id, :user => another_user.attributes}
        response.should redirect_to(root_path)
      end
      
      it 'should render edit form when user data is invalid' do
        post :update, {:id => @user.id, :user => @user.attributes.merge(:firstname => '')}
        response.should render_template(:edit)
      end
    end
  end
end
