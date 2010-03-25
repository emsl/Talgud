class Mailers::EventMailer < Mailers::Base
  
  def region_manager_notification(user, event, event_admin_url)
    with_locale(Talgud.config.mailer.manager_locale) do
      subject I18n.t('mailers.event_mailer.region_manager_notification.subject')
      setup_headers user.email
      body :user => user, :event => event, :event_admin_url => event_admin_url
    end
  end
  
  def invite_event_manager_notification(user, manager, event, login_url, password = nil)
    with_locale(Talgud.config.mailer.manager_locale) do
      subject I18n.t('mailers.event_mailer.invite_event_manager_notification.subject', :name => user.name)
      setup_headers manager.email
      body :user => user, :manager => manager, :event => event, :password => password, :login_url => login_url
    end
  end
  
  def participant_notification(event_participant, event_url, manage_url)
    subject I18n.t('mailers.event_mailer.participant_notification.subject')
    setup_headers event_participant.email
    body :event_participant => event_participant, :event_url => event_url, :manage_url => manage_url
  end

  def invite_participant_notification(event_participant, event_url, manage_url)
    subject I18n.t('mailers.event_mailer.invite_participant_notification.subject')
    setup_headers event_participant.email
    body :event_participant => event_participant, :event_url => event_url, :manage_url => manage_url
  end
  
  def manager_participation_notification(event_manager, event_participant, event_participations_url)
    subject I18n.t('mailers.event_mailer.manager_participation_notification.subject', :name => event_participant.participant_name, :event_name => event_participant.event.name)
    setup_headers event_manager.email
    body :event_participant => event_participant, :event_participations_url => event_participations_url
  end
  
  def tell_friend_notification(email, event_participant, event_url)
    subject I18n.t('mailers.event_mailer.tell_friend_notification.subject', :name => event_participant.participant_name)
    setup_headers(email)
    body :event_participant => event_participant, :event_url => event_url
  end
  
  private
  
  def setup_headers(email)
    from full_from_address
    headers 'return-path' => from_address
    recipients email
    sent_on Time.now
  end
end