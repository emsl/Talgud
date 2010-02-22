authorization do
  role :system_administrator do
    has_permission_on [:countries, :event_types, :events, :municipalities, :settelments, :users], :to => [:index, :show, :new, :create, :edit, :update, :destroy] 
  end
end