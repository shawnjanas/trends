#
# services.rb
# ================
# Contains server side commands to start & stop core services (DB, web, etc.)
#

set :engage_services, [:mongodb, :nodejs]

namespace :deploy do

  # ==> Starting / stopping services
  namespace :services do

    task :start do ; end
    task :stop do ; end

    # ==> nodejs
    namespace :nodejs do

      task :start, :roles => [:app, :web] do
        run "cd #{deploy_to}/current"
        sudo "NODE_ENV=#{sys_env} nohup #{nodejs_dir} #{deploy_to}/current/app.js > #{deploy_to}/current/log/#{sys_env}.log &"
        # sudo "NODE_ENV=#{sys_env} forever start #{deploy_to}/current/lib/client.js"
      end

      task :stop, :roles => [:app, :web] do
        sudo "kill -QUIT `ps aux | grep -E 'node.*app.js'| grep -v grep | awk '{print $2}'`"
      end
      
      task :reload, :roles => [:app, :web] do
        # TODO
        # sudo "cat #{nginx_dir}/logs/nginx.pid | xargs -r sudo kill -HUP"  # http://wiki.nginx.org/CommandLine#Stopping_or_Restarting_Nginx
      end

    end # nodejs

    namespace :redis do

      task :start, :roles => :queue do
        sudo "/etc/rc.d/init.d/redis_6379 start"
      end

      task :stop, :roles => :queue do
        sudo "/etc/rc.d/init.d/redis_6379 stop"
      end

    end # redis

    # ==> MongoDB
    #namespace :mongodb do
    #
    #  task :start, :roles => :db do
    #    sudo "/etc/init.d/mongod start"
    #    # maybe
    #    sudo "chkconfig --levels 235 mongod on"
    #  end

    #  task :stop, :roles => :db do
    #    sudo "/etc/init.d/mongod stop"
    #  end
      
    #  task :reload, :roles => :db do
    #    sudo "/etc/init.d/mongod restart"
    #  end
      
    #end # mongodb
    
    # # ==> Memcache
    # namespace :memcache do
    #   
    #   task :start, :roles => :cache do
    #     sudo "/etc/init.d/memcached start"
    #   end
    # 
    #   task :stop, :roles => :cache do
    #     sudo "kill -QUIT `cat /var/run/memcached/memcached.pid`"
    #   end
    # 
    # end # memcache
    
    # # ==> New Relic Server Monitoring
    # # https://rpm.newrelic.com/accounts/9832/servers/get_started#platform=rhel
    # namespace :new_relic do
    #   task :start do
    #     sudo "/etc/init.d/newrelic-sysmond start"
    #   end
    #   
    #   task :stop do
    #     sudo "/etc/init.d/newrelic-sysmond stop"
    #   end
    # end

  end # services

end # deploy

engage_services.each do |service|
  after "deploy:services:start", "deploy:services:#{service}:start"
end
engage_services.reverse.each do |service|
  after "deploy:services:stop",  "deploy:services:#{service}:stop"
end

after "deploy:setup", "deploy:services:start"

# These lines need to be commented out on the first deploy of code or whenever resque.rake is updated

