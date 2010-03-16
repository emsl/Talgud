class ApplicationController < ActionController::Base

  # Account select before filter must be declared before userstamp, which in turn adds one before filter that depends
  # on selected account.
  before_filter :set_locale, :select_account_and_user

  include Userstamp

  protect_from_forgery

  helper_method :current_user_session, :current_user, :current_account

  filter_parameter_logging :password

  # rescue_from Authorization::NotAuthorized do |exception|
  #   permission_denied
  # end

  protected

  def permission_denied
    flash[:error] = t('common.permission_denied')
    redirect_to root_path
  end

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
  def select_account_and_user
    Account.current = Account.first
    Authorization.current_user = current_user
  end

  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = params[:language].to_sym if params[:language]
  end  
end
