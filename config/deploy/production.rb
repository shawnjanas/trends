# ==> Environment

set :sys_env, 'production'
set :arch, 'x64'

# ==> Code Repo & Branch Config

set :branch, "master"

# ==> Server / Role Configuration

# Notes:
#   :app and :web must refer to the same machine, as nginx (web server) and passenger (app server)
#   are intimately tied together.  The natural evolution is to have a role called :load_balancer 
#   to serve requests across multiple :app/:web instances.

front_end = [
  "23.22.78.175",
]
front_end.each do |ip|
  role :web,      ip                    # Your HTTP server, Apache/etc
  role :app,      ip                    # This may be the same as your `Web` server
end

role :db,         "23.22.78.175", :primary => true  # This is where Rails migrations will run
# role :db,       "your slave db-server here"         # <== will need to change deploy:linkage:mysql to account for multiple config files
role :queue,      "107.20.21.86"                    # Queuing system
role :scheduler,  "107.20.21.86"                    # Resque-backed scheduler
role :cache,      "23.22.78.175"                    # Memcache for application caching
                  
# ==> Temp production helper machines

# HOSTFILTER can be used to target these machine individually:
# cap HOSTFILTER=107.20.131.35 production deploy:setup

workers = [
  "23.22.78.175",
]

workers.each do |worker|
  role :web,        worker
  role :app,        worker
  role :worker,     worker
end


# ==> EBS Configuration (Data Durability)

set :db_ebs_volume,         "vol-dc31e4bd"
set :db_instance_id,        "i-8816a5f0"
set :db_ebs_mount_point,    "/dev/sdh"

# ==> Only allow deploys from master branch

if current_git_branch != "master"
  puts "ERROR: Attempting to deploy to production from inappropriate git branch: #{current_git_branch.upcase}"
  exit
end
