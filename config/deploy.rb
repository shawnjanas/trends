#
# deploy.rb
# =========
#
# Capistrano deploy.rb.  We've broken out configuration / tasks to various subfiles,
# see load statements below.
# 
# Important - This file should NOT contain any tasks or variable assignments.
#             Stay organized and work with the directory/file structure under config/deploy.
#
#
# Manual deployment step(s) prior to "deploy:setup"
# -------------------------------------------------
#
# 1) ssh -i ~/.ec2/id_rsa-eqentia-keypair ec2-user@<instance-ip> 
#    sudo bash -c "cat /etc/sudoers | egrep -iv 'defaults.*tty' > /etc/sudoers.new; chmod 0440 /etc/sudoers.new; mv /etc/sudoers.new /etc/sudoers"
#
#
# Common deploy tasks
# -------------------
#
# cap production deploy:setup        # Fresh server instance, this configures our dir 
#                                    # structure and required services
#
# cap production deploy:cold         # First deploy of app, one-time event
#
# cap production deploy              # Ongoing deploy commands
# cap production deploy:migration
#
# cap <stage> deploy branch=<branch> # Deploy from a specific branch. Useful for 
#                                    # deploying feature or release branches to staging
#
#
# EBS-specific deployment steps
# -----------------------------
# 
# Connecting & mounting DB/queue/search index EBS instance:
#
# cap deploy:configuration:(mysql|redis|solr):attach_ebs_volume # Connect EBS volume to primary DB/queue/search index instance
# cap deploy:configuration:(mysql|redis|solr):mount_ebs_volume  # Mount EBS on instance OS
#
# Reference for formatting a drive (IMPORTANT: all underlying cap recipes assumg XFS):
# http://support.rightscale.com/06-FAQs/FAQ_0012_-_How_do_I_partition,_format_and_mount_an_EBS_volume%3F
#

require 'capistrano/ext/multistage'

load File.dirname(__FILE__) + '/deploy/helpers'

load File.dirname(__FILE__) + '/deploy/base'
load File.dirname(__FILE__) + '/deploy/configuration'
# load File.dirname(__FILE__) + '/deploy/plugins'
load File.dirname(__FILE__) + '/deploy/services'

