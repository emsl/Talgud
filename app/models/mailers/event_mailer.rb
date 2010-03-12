class Mailers::EventMailer < Mailers::Base
  
  def region_manager_notification(user, event, event_admin_url)
    with_locale(Talgud.config.mailer.manager_locale) do
      subject I18n.t('mailers.event_mailer.region_manager_notification.subject')
      from full_from_address
      headers 'return-path' => from_address
      recipients user.email
      sent_on Time.now
      body :user => user, :event => event, :event_admin_url => event_admin_url
    end
  end
  
  def participant_notification(event_participant, event_url, manage_url)
    subject I18n.t('mailers.event_mailer.participant_notification.subject')
    from full_from_address
    headers 'return-path' => from_address
    recipients event_participant.email
    sent_on Time.now
    body :event_participant => event_participant, :event_url => event_url, :manage_url => manage_url
  end
  
  def manager_participation_notification(event_manager, event_participant, event_participations_url)
    subject I18n.t('mailers.event_mailer.manager_participation_notification.subject', :name => event_participant.participant_name, :event_name => event_participant.event.name)
    from full_from_address
    headers 'return-path' => from_address
    recipients event_manager.email
    sent_on Time.now
    body :event_participant => event_participant, :event_participations_url => event_participations_url
  end
  
  def tell_friend_notification(email, event_participant, event_url)
    subject I18n.t('mailers.event_mailer.tell_friend_notification.subject', :name => event_participant.participant_name)
    from full_from_address
    headers 'return-path' => from_address
    recipients email
    sent_on Time.now
    body :event_participant => event_participant, :event_url => event_url
  end
end