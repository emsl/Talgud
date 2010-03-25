class FilterFormBuilder < Formtastic::SemanticFormBuilder  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
  
  def input(method, options = {})
    value = {}    
    value = template.params[:search][method] if template.params[:search]    
    value = value.to_i if is_a_number?(value)
    if options[:collection]      
      options[:selected] = value
    else
      options[:input_html] = options[:input_html].nil? ? {:value => value} : options[:input_html].merge({:value => value})
    end
    super
  end
end
