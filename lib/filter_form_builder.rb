class FilterFormBuilder < Formtastic::SemanticFormBuilder
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def is_a_boolean?(s)
    return s =~ /^true$/i || s =~ /^false$/i
  end

  def convert_to_boolean(s)
    return true if s == true || s =~ /^true$/i
    return false if s == false || s.nil? || s =~ /^false$/i
  end

  def input(method, options = {})
    value = {}
    value = template.params[:search][method] if template.params[:search]
    value = value.to_i if is_a_number?(value)
    value = convert_to_boolean(value) if is_a_boolean?(value)

    if options[:collection]
      options[:selected] = value
    else
      options[:input_html] = options[:input_html].nil? ? {:value => value} : options[:input_html].merge({:value => value})
    end
    super
  end
end
