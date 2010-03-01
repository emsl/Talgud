module Admin::AdminHelper

  def print_flash
    return '' if flash.empty?

    output = "<div style=\"padding-top: 10px;\"></div>"
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

  # Declares navigation menu as a custom array of hashes and things. It should be dynamic since navigation menu contents
  # depend on the user's role.
  def navigation_menu_contents
    [:events, :users, {:name => :counties, :active_when => [:counties, :municipalities, :settlements]}, :event_types, :languages]
  end

  def print_navigation_menu
    content_tag :ul, :id => :mainmenu, :class => :navmenu do
      navigation_menu_contents.inject('') do |memo, item|
        key, selected = case item
        when Hash
          [item[:name], item[:active_when].collect{ |i| "admin/#{i}" }.include?(request.path_parameters[:controller])]
        else
          [item, request.path_parameters[:controller] == "admin/#{item}"]
        end

        if key and permitted_to?(:manage, "admin_#{key}".to_sym)
          memo << content_tag(:li) do
            link_to t("admin.#{key}.index.title"), send("admin_#{key}_path"), :class => if selected then 'active' end
          end
        end
        memo
      end
    end
  end

  # Builds printable label from user name and email
  def label_for_user(user)
    [user.name, user.email].join(', ')
  end

  # Builds list of regional managers for given region model.
  def regional_managers_for_object(obj)
    managers = obj.try(:regional_managers)
    manager_names = managers.collect(&:name) if managers
    content = []
    content << truncate(manager_names.join(', '), 30) unless manager_names.empty?
    content << if manager_names.empty?
      link_to t(".add_role"), new_admin_role_path(:model_type => obj.class.name, :model_id => obj), :class => :action
    else
      link_to t(".edit_role"), new_admin_role_path(:model_type => obj.class.name, :model_id => obj), :class => :action
    end
    
    content_tag :div do
      content.join(' ')
    end
  end
end
