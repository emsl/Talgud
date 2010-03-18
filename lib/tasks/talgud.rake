class Hash
  def deep_stringify_keys
    new_hash = {}
    self.each do |key, value|
      new_hash.merge!(key.to_s => (value.is_a?(Hash) ? value.deep_stringify_keys : value))
    end
  end

  def deep_merge!(second)
    merger = proc { |key,v1,v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge!(second, &merger)
  end

  def nested_hash(array)
    node = self
    array.each do |i|
      node[i]=Hash.new if node[i].nil?
      node = node[i]
    end
    self
  end

  def merge_nested_hash!(nested_hash)
    deep_merge!(nested_hash)
  end
end

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
          user = User.create! :firstname => 'Default', :lastname => 'Administrator', :phone => '123', :password => args[:manager_password],
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

  namespace :yaml do
    desc 'Merge two YAML files'

    def write(filename, hash)
      File.open(filename, "w") do |f|
        f.write(yaml(hash))
      end
    end

    def yaml(hash)
      method = hash.respond_to?(:ya2yaml) ? :ya2yaml : :to_yaml
      string = hash.deep_stringify_keys.send(method)
      string.gsub("!ruby/symbol ", ":").sub("---","").split("\n").map(&:rstrip).join("\n").strip
    end

    task :merge, :primary, :new, :target, :needs => :environment do |t, args|
      require 'ya2yaml'
      
      if args[:primary] and args[:new] and args[:target]
        primary_yml = YAML::load_file(args[:primary])
        new_yml = YAML::load_file(args[:new])
        target = primary_yml.merge_nested_hash!(new_yml)
        write(args[:target], target)
      else
        puts "Please specify primary, new and target YAML files!"
      end
    end
  end
end
