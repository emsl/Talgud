# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def print_flash
    return '' if flash.empty?
    
    output = ''
    flash.each do |key, message|
      output << "<div class=\"#{key}\">"
      if message.is_a?(Hash) && message[:base]
        output << "<b>#{message[:base]}</b>"
        message[:messages].each do |error|
          output << "<br/>#{error}" unless error == message[:base]
        end
      else
        output << "<b>#{message}</b>"
      end
      output << "</div>"
    end
    output
  end

  # Will paginate method override.
  def paginate(collection = nil)
    will_paginate collection, :previous_label => t('common.paginate_previous'), :next_label => t('common.paginate_next')
  end  
  
  def language_menu(code, title)    
    if I18n.locale == code
      content_tag :span, :class => :active do
        title
      end
    else
      link_to title, language_path(:language => code)
    end
  end  
  
  # Set required headers for CSV file serving as attachment. Also solved special case with IE.
  def csv_headers(filename)
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end
  end
end