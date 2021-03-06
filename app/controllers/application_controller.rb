class ApplicationController < ActionController::Base

  # Account select before filter must be declared before userstamp, which in turn adds one before filter that depends
  # on selected account.
  before_filter :set_locale, :select_account_and_user, :hijack_ie_default_format

  include Userstamp

  protect_from_forgery

  helper_method :current_user_session, :current_user, :current_account, :get_locale

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
    Account.current = if Talgud.config.domain
      Account.find_by_domain(Talgud.config.domain)
    else
      Account.first
    end
    Authorization.current_user = current_user
  end

  def set_locale
    session[:language] = params[:language].is_a?(String) ? params[:language].to_sym : params[:language] if params[:language]
    I18n.locale = APPLICATION_LANGUAGES.include?(session[:language]) ? session[:language] : I18n.default_locale
  end
  
  def get_locale
    I18n.locale
  end
  
  def hijack_ie_default_format
    if request.user_agent =~ /MSIE/ and params['format'].nil?
      params['format'] = 'html'
    end
  end
end
