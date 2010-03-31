module EventsHelper

  # Displays event start and end hours in a simple format, i.e. when event starts at 12:00 and ends 18:00, the result
  # would be 12-18
  def duration_times(event)
    [event.begins_at.try(:hour), event.ends_at.try(:hour)].compact * '-'
  end

  def duration_dates(event)
    # event.begins_at.strftime('%d.%b')
    l(event.begins_at.to_date, :format => :short)
  end

  # Displays event registration start and end hours in a simple format, i.e. when event starts at 12:00 and ends 18:00, the result
  # would be 12-18
  def format_time(date)
    date.try(:hour)
  end

  def format_date(date)
    l(date.to_date, :format => :short)
  end

  # Returns language names associated with event as sentence.
  def languages_label(event)
    event.languages.collect(&:name) * ', '
  end

  def select_options_for_language
    Language.sorted.collect do |l|
      [l.name, l.id]
    end
  end
  
  def manager_contacts(manager)
    [manager.name, manager.email, manager.phone].select{ |i| not i.blank? } * ', '
  end

  def all_manager_contacts(managers)
    return '' unless managers
    contacts = managers.collect do |manager|
      manager_contacts(manager)
    end
    contacts * '; '
  end

  def all_manager_names(managers)
    return '' unless managers
    managers.collect(&:name).select{ |i| not i.blank? } * ', '
  end

  def all_manager_emails(managers)
    return '' unless managers
    managers.collect(&:email).select{ |i| not i.blank? } * ', '
  end

  def all_manager_phones(managers)
    return '' unless managers
    managers.collect(&:phone).select{ |i| not i.blank? } * ', '
  end
end
