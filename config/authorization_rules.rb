authorization do
  role :guest do
    has_permission_on [:home], :to => [:read]
    has_permission_on [:user_sessions], :to => [:manage]
    has_permission_on [:events], :to => [:read]
  end

  role :event_manager do
    includes :guest
    has_permission_on [:event_participant], :to => [:manage]
    has_permission_on [:events], :to => [:my_events, :manage]
  end

  role :event_participant do
    has_permission_on [:event_participants], :to => [:manage]
  end

  role :regional_manager do
    has_permission_on [:admin_events], :to => [:manage, :map]
  end

  role :account_manager do
    has_permission_on [:admin_counties, :admin_event_types, :admin_municipalities, :admin_settelments, :admin_users, :admin_languages], :to => [:manage]
    has_permission_on [:admin_events], :to => [:manage, :map]
  end
end

privileges do
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end