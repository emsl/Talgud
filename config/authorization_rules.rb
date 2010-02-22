authorization do
  role :account_manager do
    has_permission_on [:admin_countries, :admin_event_types, :admin_events, :admin_municipalities, :admin_settelments, :admin_users], :to => [:manage]
  end

  role :regional_manager do
    has_permission_on [:admin_events], :to => [:manage]
  end

  role :event_manager do
    has_permission_on [:events], :to => [:manage]
    has_permission_on [:event_participant], :to => [:manage]
  end

  role :event_participant do
    has_permission_on [:event_participants], :to => [:manage]
  end

  role :guest do
    has_permission_on [:home], :to => [:see]
    has_permission_on [:user_sessions], :to => [:manage]
    has_permission_on [:events], :to => [:see]
  end

  role :user do
    #has_permission_on [:events], :to => [:logout]
  end
end

privileges do
  privilege :manage do
    includes :show, :new, :create, :edit, :update, :destroy, :see
  end

  privilege :see do
    includes :index, :show
  end
end
