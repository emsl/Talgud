Factory.define :account do |a|
  a.name 'Account'
  a.domain 'test.local'
end

Factory.define :user do |u|
  u.firstname 'Admin'
  u.lastname 'User'
  u.sequence(:email) { |n| "admin#{n}@example.com" }
  u.password 'admin'
  u.password_confirmation 'admin'
  u.status User::STATUS[:active]
end

Factory.define :user_not_activated, :parent => :user do |u|
  u.perishable_token 'perishable_token'
  u.status User::STATUS[:created]
end