set :stages, %w(production staging)
require 'capistrano/ext/multistage'

set :application, 'Talgud'

deploy.task :after_update, :roles => [:app] do
  desc <<-DESC
    After code update, this hook will upload your configuration files from config/ to server. Please
    note that it is not advised to store configuration files in public code repository.
  DESC
  top.upload('./config/database.yml', "#{release_path}/config/database.yml")
  top.upload('./config/app_config.yml', "#{release_path}/config/app_config.yml")
  top.upload('./config/newrelic.yml', "#{release_path}/config/newrelic.yml")
end

deploy.task :after_update_code, :roles => [:app] do
  desc <<-DESC
    After update code set correct group ownership and permissions for updated application code.
  DESC
  sudo "chown -R #{user}:#{files_group} #{release_path}/"
  sudo "mkdir -p #{release_path}/tmp/cache"
  sudo "chown -R #{user}:#{files_group} #{release_path}/tmp/cache"
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
