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
    [
      {:name => :events, :active_when => [:events, :event_participants]},
      {:name => :participants, :active_when => [:participants]},
      :users,
      {:name => :counties, :active_when => [:counties, :municipalities, :settlements]},
      :event_types, :languages, :roles, :accounts
    ]
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
  def managers_for_object(obj, truncate_length = 20)
    managers = obj.try(:managers)
    manager_names = managers.collect(&:name) if managers
    content = if manager_names.empty?
      if permitted_to?(:manage, :admin_roles)
        link_to t(".add_role"), new_admin_role_path(:model_type => obj.class.name, :model_id => obj), :class => :low_priority
      else
        ''
      end
    else
      if permitted_to?(:manage, :admin_roles)
        link_to(truncate(manager_names.join(', '), :length => truncate_length), new_admin_role_path(:model_type => obj.class.name, :model_id => obj), :title => t(".edit_role"))
      else
        truncate(manager_names.join(', '), :length => truncate_length)
      end
    end

    content_tag :div do
      content
    end
  end
  
  # Check if view is currently filtered.
  def filtering?
    not params[:search].nil?
  end
  
  # Displays notification row that view is currently filtered
  def filter_notify(colspan)
    render :partial => 'shared/admin/filter_notify', :locals => {:colspan => colspan}
  end
  
  
end
