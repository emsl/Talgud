authorization do
  role :account_manager do
    has_permission_on [:admin_counties, :admin_event_types, :admin_events, :admin_municipalities, :admin_settelments, :admin_users, :admin_languages], :to => [:manage]
  end

  role :regional_manager do
    has_permission_on [:admin_events], :to => [:manage]
  end

  role :event_manager do
    includes :guest
    has_permission_on [:events], :to => [:manage]
    has_permission_on [:event_participant], :to => [:manage]
    has_permission_on [:events], :to => [:create, :read]
    has_permission_on [:my_events], :to => [:read, :update] do
      if_attribute :status => is {'finished'}
      if_attribute :status => is {'new'}
      if_attribute :status => is {'denied'}
    end
  end

  role :event_participant do
    has_permission_on [:event_participants], :to => [:manage]
  end

  role :guest do
    has_permission_on [:home], :to => [:read]
    has_permission_on [:user_sessions], :to => [:manage]
    has_permission_on [:events], :to => [:read] do
      if_attribute :status => is {'published'}
      if_attribute :status => is {'registration_open'}
      if_attribute :status => is {'registration_closed'}
    end
  end
end

privileges do
  privilege :manage do
    includes :create, :edit, :destroy, :read
  end

  privilege :create do
    includes :new, :create
  end
  privilege :edit do
    includes :edit, :update
  end
  privilege :read do
    includes :index, :show
  end
end
