class ApplicationController < ActionController::Base

  # Account select before filter must be declared before userstamp, which in turn adds one before filter that depends
  # on selected account.
  before_filter :select_account

  include Userstamp

  protect_from_forgery

  helper_method :current_user_session, :current_user, :current_account

  filter_parameter_logging :password
  
  protected
  
  def require_user
    unless current_user
      flash[:notice] = t('user_sessions.new.login_required')
      redirect_to login_path
      return false
    end
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def current_account
    Account.current
  end
  
  # TODO: select account and throw an error if not found
  def select_account
    Account.current = Account.first
  end
end
