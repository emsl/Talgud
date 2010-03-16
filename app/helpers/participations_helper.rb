module ParticipationsHelper
  def column_class_name(obj, field, force_classname = nil)
    classes = [force_classname]
    classes << 'error' if obj.errors.on(field)
    " class=\"#{classes.compact.join(' ')}\""
  end
end
