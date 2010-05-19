module ParticipationsHelper
  def column_class_name(obj, field, force_classname = nil)
    classes = [force_classname]
    classes << 'error' if obj.errors.on(field)
    " class=\"#{classes.compact.join(' ')}\""
  end
  
  def age_range_options
    [[t('.choose_age_range'), '']] + (1..8).collect { |i| [age_range_label(i), i]}
  end
  
  def age_range_label(value)
    return '' if value.blank?
    
    t("formtastic.labels.event_participant.age_ranges.#{value}")
  end
  
  def notes_label(event_participant)
    [t('formtastic.labels.event_participant.notes'), event_participant.event.registration_notes_title] * ': '
  end
end
