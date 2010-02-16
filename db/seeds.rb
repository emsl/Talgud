# Creates initial user for database
User.create!(:firstname => 'Admin', :lastname => 'User', :email => 'admin@example.com', :password => 'admin', :password_confirmation => 'admin')
