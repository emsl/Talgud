set :stages, %w(production staging)
require 'capistrano/ext/multistage'

set :application, 'Talgud'

deploy.task :after_update, :roles => [:app] do
  desc <<-DESC
    After code update, this hook will upload your database configuration file from config/database.yml to server. Please
    note that it is not advised to store this file in your code repository.
  DESC
  top.upload('./config/database.yml', "#{release_path}/config/database.yml")
end

deploy.task :after_update_code, :roles => [:app] do
  desc <<-DESC
    After update code set correct group ownership and permissions for updated application code.
  DESC
  sudo "chown -R #{user}:#{files_group} #{release_path}/"
end

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  task :start do
    run "touch #{current_path}/tmp/restart.txt"
  end
  task :stop do; end
end
