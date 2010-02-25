class Admin::AdminController < ApplicationController

  before_filter :require_user

  layout 'admin'
  
  helper 'admin/admin'

  protected
  
  def require_user
    unless current_user
      flash[:notice] = t('user_sessions.new.login_required')
      redirect_to admin_login_path
      return false
    end
  end
end
