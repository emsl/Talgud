module EventsHelper
  
  # Displays event start and end hours in a simple format, i.e. when event starts at 12:00 and ends 18:00, the result
  # would be 12-18
  def duration_times(event)
    [event.begins_at.try(:hour), event.ends_at.try(:hour)].compact * '-'
  end
  
  def duration_dates(event)
    event.begins_at.strftime('%d.%m')
  end

  # Returns language names associated with event as sentence.
  def languages_label(event)
    event.languages.collect(&:name) * ', '
  end
end
