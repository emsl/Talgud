class Admin::UsersController < Admin::AdminController
  
  def index
    @users = User.all
  end

  def new
  end

  def edit
  end

end
