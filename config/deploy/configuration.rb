#
# configuration.rb
# ================
# Contains all one-time server configuration tasks for engage
#

namespace :deploy do

  namespace :configuration do

    task :ownership do
      # sudo "touch #{deploy_to}"
      sudo "chown -R #{user}.#{user} #{deploy_to}"
    end
    
    task :base do
      sudo "yum install -y git curl gcc libgcc make patch zlib-devel zlib openssl openssl-devel libcurl libcurl-devel gcc-c++ libxml2 libxml2-devel libxslt libxslt-devel xfsprogs readline-devel libtool pcre-devel"
    end
    
    namespace :nodejs do
      task :install, :roles => [:app, :web] do
        run "wget http://nodejs.org/dist/v0.8.4/node-v0.8.4.tar.gz"
        run "tar xzvf node-v0.8.4.tar.gz"
        run "cd node-v0.8.4"
        # TODO: these 3 aren't working from cap
        run "./configure"
        run "make"
        sudo "make install"
        sudo "/usr/local/bin/npm install forever -g --force"
      end
    end

    #namespace :mongodb do
      
    #  task :install, :roles => :db do
    #    # TODO: test this out for 1st time
    #    sudo "mkdir -p /etc/yum.repos.d/"
    #    transfer(:up, "#{File.dirname(__FILE__)}/../mongodb/#{sys_env}-10gen.repo", "/tmp/10gen.repo")
    #    if arch == 'x32'
    #      sudo "mv /tmp/10gen.repo /etc/yum.repos.d/10gen.repo"
    #      sudo "yum -y install sysstat"
    #      sudo "yum -y install mongo-10gen mongo-10gen-server"
    #    else
    #      run "wget http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/RPMS/mongo-10gen-2.0.6-mongodb_1.x86_64.rpm"
    #      sudo "yum -y install mongo-10gen-2.0.6-mongodb_1.x86_64.rpm"
    #      run "wget http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/RPMS/mongo-10gen-server-2.0.6-mongodb_1.x86_64.rpm"
    #      sudo "yum -y install mongo-10gen-server-2.0.6-mongodb_1.x86_64.rpm"
    #    end
        # TODO: move these to /vol and /var
        # sudo "chown mongod:mongod /data"
        # sudo "chown mongod:mongod /log"
        # sudo "chown mongod:mongod /journal"
    #    sudo "chkconfig mongod on"
    #  end

      # TODO: setup volumes
    #  task :detach_ebs_volume, :roles => :db, :only => {:primary => true} do
    #    system "ec2-detach-volume #{db_ebs_volume}"
    #  end
      # 
    #  task :attach_ebs_volume, :roles => :db, :only => {:primary => true} do
    #    system "ec2-attach-volume #{db_ebs_volume} -i #{db_instance_id} -d #{db_ebs_mount_point}"
    #  end
      # 
    #  task :mount_ebs_volume, :roles => :db, :only => {:primary => true} do
    #    mount_volume(
    #      :ebs_device =>  db_ebs_mount_point,
    #      :mount_point => "/vol/mongo",
    #      :data_dir =>    "/var/lib/mongo",
    #      :owner =>       "mongod.mongod"
    #    )
    #  end
    #  task :umount_ebs_volume, :roles => :db, :only => {:primary => true} do
    #    umount_volume(
    #      :ebs_device =>  db_ebs_mount_point,
    #      :mount_point => "/vol/mongo",
    #      :data_dir =>    "/var/lib/mongo",
    #      :owner =>       "mongod.mongod"
    #    )
    #  end
      # 
    #end

    namespace :redis do

      task :install, :roles => :queue do
        run "wget http://redis.googlecode.com/files/redis-2.4.1.tar.gz"
        run "tar xzvf redis-2.4.1.tar.gz"
        run "cd redis-2.4.1 && make"
        sudo "cp redis-2.4.1/src/redis-server /usr/local/bin"
        sudo "cp redis-2.4.1/src/redis-cli /usr/local/bin"

        sudo "mkdir -p /etc/redis"
        sudo "mkdir -p /var/redis"
        sudo "mkdir -p /var/redis/6379"

        transfer(:up, "#{File.dirname(__FILE__)}/../redis/redis.conf",         "/home/#{user}/redis.conf")
        transfer(:up, "#{File.dirname(__FILE__)}/../redis/redis_init_script",  "/home/#{user}/redis_init_script")
        sudo "ln -f -s /home/#{user}/redis_init_script /etc/rc.d/init.d/redis_6379"
        sudo "ln -f -s /home/#{user}/redis.conf /etc/redis/6379.conf"
        sudo "chmod a+x /etc/rc.d/init.d/redis_6379"
      end

      #task :attach_ebs_volume, :roles => :queue do
      #  system "ec2-attach-volume #{queue_ebs_volume} -i #{queue_instance_id} -d #{queue_ebs_mount_point}"
      #end
      
      #task :mount_ebs_volume, :roles => :queue do
      #  mount_volume(
      #    :ebs_device =>  queue_ebs_mount_point,
      #    :mount_point => "/vol/redis",
      #    :data_dir =>    "/var/redis"
      #  )
      #end
      
    end
    

    namespace :authentication do

      task :install_ssh_keys do
        transfer(:up, "#{File.dirname(__FILE__)}/../ssh/id_rsa.pub", "/home/#{user}/.ssh/id_rsa.pub")
        transfer(:up, "#{File.dirname(__FILE__)}/../ssh/id_rsa",     "/home/#{user}/.ssh/id_rsa")
        transfer(:up, "#{File.dirname(__FILE__)}/../ssh/id_dsa.pub", "/home/#{user}/.ssh/id_dsa.pub")
        transfer(:up, "#{File.dirname(__FILE__)}/../ssh/id_dsa",     "/home/#{user}/.ssh/id_dsa")
        run "chmod 600 /home/#{user}/.ssh/id*"
        run "/bin/cat /home/#{user}/.ssh/id_dsa.pub >> /home/#{user}/.ssh/authorized_keys"
        run "cd ~/.ssh && eval `ssh-agent` && ssh-add"
      end
      
      task :install_ca_cert do
        transfer(:up, "#{File.dirname(__FILE__)}/../ca_cert/cacert.pem", "/home/#{user}/cacert.pem")
        sudo "mkdir -p /opt/ca_cert"
        sudo "cp /home/#{user}/cacert.pem /opt/ca_cert/cacert.pem"
      end

    end # authentication

    namespace :ssh do
      
      task :setup_known_hosts do
        transfer(:up, "#{File.dirname(__FILE__)}/../ssh/known_hosts", "/home/#{user}/.ssh/known_hosts")
      end
      
    end # ssh
    
    # # ==> New Relic Server monitoring
    # # https://rpm.newrelic.com/accounts/9832/servers/get_started#platform=rhel
    # namespace :new_relic do
    #   
    #   task :install do
    #     sudo "rpm -Uvh http://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm"
    #     sudo "yum -y install newrelic-sysmond"
    #     sudo "nrsysmond-config --set license_key=3cc10442207fc695832f7111866527a4412d7a60"
    #   end
    #   
    # end # new_relic
    
    
    # # ==> Memcache for caching purposes
    # namespace :memcache do
    #   task :install, :roles => :cache do
    #     sudo "yum -y install memcached"
    #   end
    # end
  
  end # configuration

end # deploy

# via http://www.pgrs.net/2008/08/06/switching-users-during-a-capistrano-deploy/
def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end

after "deploy:setup", "deploy:configuration:ownership"
after "deploy:setup", "deploy:configuration:base"
after "deploy:setup", "deploy:configuration:nodejs:install"
after "deploy:setup", "deploy:configuration:redis:install"
after "deploy:setup", "deploy:configuration:authentication:install_ssh_keys"
after "deploy:setup", "deploy:configuration:authentication:install_ca_cert"
after "deploy:setup", "deploy:configuration:ssh:setup_known_hosts"
