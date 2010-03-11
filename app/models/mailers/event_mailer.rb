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
  
  def participant_notification(event, event_participation)
    
  end
  
  def manager_paricipation_notification(event, event_manager, event_participation)
    
  end
  
  def tell_friend_notification(email, event, event_participation)
    
  end
end