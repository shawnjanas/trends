# ==> Environment

set :sys_env, 'staging'
set :arch, 'x64'


# ==> Code Repo & Branch Config
if ARGV.find{|x| x=~/^branch=(.*)/}
  # custom git branch
  set :branch, $1
else
  # default giot branch
  set :branch, ENV.has_key?('branch') ? ENV['branch'] : "develop"
end

# ==> Server / Role Configuration

# Notes:
#   :app and :web must refer to the same machine, as nginx (web server) and passenger (app server)
#   are intimately tied together.  The natural evolution is to have a role called :load_balancer 
#   to serve requests across multiple :app/:web instances.

role :web,        "ec2-50-16-52-45.compute-1.amazonaws.com"                    # Your HTTP server, Apache/etc
role :app,        "ec2-50-16-52-45.compute-1.amazonaws.com"                    # This may be the same as your `Web` server
role :db,         "ec2-50-16-52-45.compute-1.amazonaws.com", :primary => true  # This is where Rails migrations will run
# role :db,       "your slave db-server here"         # <== will need to change deploy:linkage:mysql to account for multiple config files
#role :queue,      "184.72.160.160"                    # Queuing system
# role :index,      "107.21.73.8", :primary => true  # Search index
#role :scheduler,  "184.72.160.160"                    # Resque-backed scheduler
#role :cache,      "107.21.73.8"                    # Memcache for application caching


#workers = [
#  "107.21.73.8",
#]
#workers.each do |worker|
#  role :web,        worker
#  role :app,        worker
#  role :worker,     worker
#end


# ==> EBS Configuration (Data Durability)

#set :db_ebs_volume,         "vol-c2cde0ac"
#set :db_instance_id,        "i-fcf1f685"
#set :db_ebs_mount_point,    "/dev/sdh"

# ==> Only allow deploys from develop, release, or feature branches

if !(current_git_branch == "develop" || current_git_branch =~ /^(release|feature)\//)
  puts "ERROR: Attempting to deploy to staging from inappropriate git branch: #{current_git_branch.upcase}"
  exit
end
