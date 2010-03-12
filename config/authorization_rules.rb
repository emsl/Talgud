authorization do
  role :guest do
    has_permission_on [:home], :to => [:read]
    has_permission_on [:user_sessions, :admin_user_sessions], :to => [:manage]
    has_permission_on [:event_participants], :to => [:create] do
      #if_attribute :event => {:vacancies => is {Proc.new {|p| p.vacancies > 0}}}
    end
    has_permission_on [:events], :to => [:read, :map, :latest] do
      if_attribute :status => Event::STATUS[:published]
      if_attribute :status => Event::STATUS[:registration_open]
      if_attribute :status => Event::STATUS[:registration_closed]
    end
  end

  role :event_manager do
    includes :guest
    has_permission_on [:event_participants], :to => [:manage] do
      if_attribute :event => {:managers => contains {user}}
    end
    
    has_permission_on [:events], :to => [:create]
    has_permission_on [:events], :to => [:my, :show, :update] do
      if_attribute :managers => contains {user}
    end
    has_permission_on [:users], :to => [:update] do
      if_attribute :id => is {user.id}
    end
  end

  role :event_participant do
    includes :guest
    has_permission_on [:event_participants], :to => [:manage]
  end

  role :regional_manager do
    includes :guest
    has_permission_on [:admin_events], :to => [:manage, :read, :map] do
    end
  end

  role :account_manager do
    includes :guest
    has_permission_on [:admin_roles, :admin_counties, :admin_event_types, :admin_municipalities, :admin_settlements, :admin_users, :admin_languages, :admin_events], :to => [:manage, :map] do
    end
    has_permission_on [:admin_accounts], :to => [:manage] do
      if_attribute :roles => {:user => contains {user}, :role => Role::ROLE[:account_manager]}
    end
  end
end

privileges do
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => [:new, :create]
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
