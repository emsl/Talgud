# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def urls_to_links(input, options = {})
    regex = Regexp.new '((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'
    target = if options[:target] then " target=\"#{options[:target]}\"" else '' end
    input.gsub!(regex, '<a href="\1"' + target + '>\1</a>')
  end

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
  
end
