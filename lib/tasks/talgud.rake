namespace :talgud do
  namespace :account do
    desc 'Create new system account for domain'
    task :create, :name, :domain, :manager_email, :manager_password, :needs => :environment do |t, args|
      Account.transaction do

        account = Account.find_by_domain(args[:domain])
        unless account
          account = Account.create! :name => args[:name], :domain => args[:domain]
          puts "Created new account '#{account.name}' for domain '#{account.domain}'."
        end
        Account.current = account

        user = User.find_by_email(args[:manager_email])
        unless user
          user = User.create! :firstname => 'Default', :lastname => 'Administrator', :password => args[:manager_password],
          :password_confirmation => args[:manager_password], :email => args[:manager_email]
          puts "Created default account manager '#{user.email}' for domain '#{account.domain}'."
        else
          puts "Found existing user '#{user.email}'."
        end

        unless user.active?
          user.activate!
          puts "User '#{user.email}' activated."
        end

        unless Role.has_role?(Role::ROLE[:account_manager], user, account)
          Role.grant_role(Role::ROLE[:account_manager], user, account)
          puts "Granted role account manager to user #{user.name} for domain '#{account.domain}'."
        end
      end
    end
  end
end
