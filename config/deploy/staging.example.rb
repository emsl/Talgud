#
# * Copy this file to staging.rb
#
# Configuration parameters defined in production.rb will be used when deploying to production environment via calling
# capistrano with 'cap staging deploy'.

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
