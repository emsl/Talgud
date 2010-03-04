Factory.define :account do |a|
  a.name 'Account'
  a.sequence(:domain) { |n| "test#{n}.local" }
end

Factory.define :county do |c|
  c.sequence(:name) { |n| "County #{n}" }
end

Factory.define :language do |m|
  m.name 'English'
  m.sequence(:code) { |n| "lang_#{n}"}
end

Factory.define :municipality do |m|
  m.sequence(:name) { |n| "Municipality #{n}" }
  m.kind Municipality::KIND.first
  m.association :county
end

Factory.define :settlement do |s|
  s.sequence(:name) { |n| "Settlement #{n}" }
  s.kind Settlement::KIND.first
  s.association :municipality
end

Factory.define :event_type do |et|
  et.sequence(:name) { |n| "Event type #{n}" }
end

Factory.define :event do |e|
  e.sequence(:name) { |n| "Event #{n}" }
  e.begins_at 1.day.from_now
  e.ends_at 2.days.from_now
  e.location_address_country_code 'ee'
  e.status Event::STATUS[:published]
  e.max_participants 10
  e.location_address_street 'Location address'

  # Metadata
  e.gathering_location 'Gathering location'
  e.notes 'Notes'
  e.meta_bring_with_you 'Bring with you :)'
  e.meta_provided_for_participiants 'Provided for participants'
  e.meta_subject_info 'Subject info'
  e.meta_subject_owner 'Subject owner'
  e.meta_aim_description 'Aim description'
  e.meta_job_description 'Job description'
  
  e.association :event_type
  e.association :location_address_county, :factory => :county
  e.association :location_address_municipality, :factory => :municipality
  e.association :manager, :factory => :user
  
  e.languages do |event|
    [event.association(:language)]
  end
end

Factory.define :role_system_administrator, :class => Role do |r|
  r.role Role::ROLE[:system_administrator]
  r.association :user
  r.association :model, :factory => :account
end

Factory.define :role do |r|
  r.association :user
  r.role Role::ROLE[:regional_manager]
  r.association :model, :factory => :county
end

Factory.define :user do |u|
  u.firstname 'Admin'
  u.lastname 'User'
  u.sequence(:email) { |n| "admin#{n}@example.com" }
  u.phone '+232322323'
  u.password 'admin'
  u.password_confirmation 'admin'
  u.status User::STATUS[:active]
end

Factory.define :code_sequence do |c|
  c.sequence(:code) { |n| "code#{n}" }
  c.sequence(:sequence) { |n| "sequence#{n}" }
end

Factory.define :user_not_activated, :parent => :user do |u|
  u.perishable_token 'perishable_token'
  u.status User::STATUS[:created]
end