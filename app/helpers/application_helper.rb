# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def urls_to_links(input, options = {})
    regex = Regexp.new '((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)'
    target = if options[:target] then " target=\"#{options[:target]}\"" else '' end
    input.gsub!(regex, '<a href="\1"' + target + '>\1</a>')
  end
  
end
