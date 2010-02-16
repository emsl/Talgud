Factory.define(:user) do |u|
  u.firstname 'Admin'
  u.lastname 'User'
  u.sequence(:email) { |n| "admin#{n}@example.com" }
  u.password 'admin'
end