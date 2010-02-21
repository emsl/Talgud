namespace :talgud do
  namespace :account do
    desc 'Create new system account for domain'
    task :create, :name, :domain, :needs => :environment do |t, args|
      account = Account.create! :name => args[:name], :domain => args[:domain]
      puts "Created new account '#{account.name}' for domain '#{account.domain}'."
    end
  end
end