authorization do
  role :guest do
    has_permission_on [:home], :to => [:read]
    has_permission_on [:user_sessions, :admin_user_sessions], :to => [:manage]
    has_permission_on [:events], :to => [:read, :map] do 
      if_attribute :status => is { Event::STATUS[:published]}
      if_attribute :status => is { Event::STATUS[:registration_opened]}
      if_attribute :status => is { Event::STATUS[:registration_closed]}
    end
  end

  role :event_manager do
    includes :guest
    has_permission_on [:event_participant], :to => [:manage]
    has_permission_on [:events], :to => [:my, :update], :join_by => :and do
      if_attribute :roles => {:user => contains {user} }
      if_attribute :roles => {:role => Role::ROLE[:event_manager] }
    end
  end

  role :event_participant do
    includes :guest
    has_permission_on [:event_participants], :to => [:manage]
  end

  role :regional_manager do
    includes :guest
    has_permission_on [:admin_events], :to => [:manage, :map]
  end

  role :account_manager do
    includes :guest
    has_permission_on [:admin_counties, :admin_event_types, :admin_municipalities, :admin_settelments, :admin_users, :admin_languages, :admin_events], :to => [:manage, :map], :join_by => :and do
      # if_attribute :roles => {:user => contains {user} }
      # if_attribute :roles => {:role => Role::ROLE[:account_manager] }      
    end
  end
end

privileges do
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end