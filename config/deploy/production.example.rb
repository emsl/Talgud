#
# * Copy this file to production.rb
#
# Configuration parameters defined in production.rb will be used when deploying to production environment via calling
# capistrano with 'cap production deploy'.

set :user, '<server_username>'
set :password, '<server_password>'
set :files_owner, '<files_owner>'
set :files_group, '<files_group>'
set :rails_env, '<rails_environment>'
set :domain, '<your_host_domain>'

role :app, domain
role :web, domain
role :db, domain, :primary => true

set :deploy_to, '/deploy/to/path/'

set :scm, :git
set :repository, '<git_repository_url>'
set :branch, '<git_branch_name>'
set :deploy_via, :remote_cache
set :ssh_options, {:forward_agent => true}

set(:confirmed) do
  puts <<-WARN
  
  ========================================================================
  
    WARNING: You're about to perform actions on production server(s)
    Please confirm that all your intentions are kind and friendly
  
  ========================================================================
  
  WARN
  answer = Capistrano::CLI.ui.ask "  Are you sure you want to continue? (Y) "
  if answer == 'Y' then true else false end
end

after 'multistage:ensure' do
  unless confirmed
    puts "\nDeploy cancelled!"
    exit
  end
end
