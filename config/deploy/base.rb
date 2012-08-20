#
# base.rb
# =======
# Contains all base deployment configuration and recipes for engage project
#

set :application, "trends"
set :repository,  "git@github.com:shawnjanas/trends"
set :deploy_to, "/mnt/#{application}"
set :nodejs_dir, "/usr/local/bin/node"
set :log_dir,    "/var/log"
set :keep_releases, 10 # Keep the 10 most recent releases
set :scm, :git
set :user, "ubuntu"
# set :db_server_id, ARGV.find{|x| x=~/^db_server=(.*)/} ? $1 : 'master-1'
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "trends_key")]


namespace :deploy do

  # ==> Passenger mod_rails start/stop hooks:
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => [:app, :web], :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  # ==> Configuration file linkage
  namespace :linkage do

    task :nodejs, :roles => [:app, :web] do
      #TODO
    end

    task :mongodb, :roles => :db do
      # TODO
      #db_server = db_server_id ? "#{stage}-#{db_server_id}" : stage
    end

    # TODO: setup logrotate on mongodb and nodejs log files
    # namespace :logrotate do
    #   task :mysql_slow, :roles => :db do
    #     sudo "ln -f -s #{File.join(current_path,'config','logrotate','mysql-slow')} /etc/logrotate.d/mysql-slow"
    #   end
    #   task :engagio, :roles => [:app, :web] do
    #     sudo "ln -f -s #{File.join(current_path,'config','logrotate','engagio')} /etc/logrotate.d/engagio"
    #   end
    # end

  end # linkage
  
  # ==> Asset Precompilation
  namespace :assets do
    task :precompile, :roles => [:app, :web] do
      run "cd #{release_path}; npm install"
    end
    
  end # assets
  
  
  # TODO: setup a siple admin view for status of system
  # ==> Maintenance Page
  # namespace :web do
  #   
  #   task :disable, :roles => [:app, :web] do
  #     run "touch #{shared_path}/offline.txt"
  #   end
  # 
  #   task :enable, :roles => [:app, :web] do
  #     run "rm #{shared_path}/offline.txt; true"
  #   end
  #   
  # end
  
end # deploy

after "deploy:update_code",   "deploy:linkage:nodejs"
after "deploy:linkage:nodejs", "deploy:services:nodejs:reload"

after "deploy:update_code", "deploy:linkage:mongodb"
after "deploy:linkage:mongodb", "deploy:services:mongodb:reload"

# TODO: setup logrotate
# after "deploy:update_code", "deploy:linkage:logrotate:mysql_slow"
# after "deploy:update_code", "deploy:linkage:logrotate:engagio"

after "deploy:update_code", "deploy:assets:precompile"

after "deploy",            "deploy:cleanup"
