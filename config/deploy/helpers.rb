#
# capistrano_helpers.rb
# =====================
# This file contains some helper methods that can be used during the our capistrano deploy.
# Consolidated here to 1) reduce the complexity of deploy.rb and 2) for maintainability
#

def current_git_branch
  `git branch`.split("\n").find{|i| i =~ /^\*/}.gsub(/[\* ]/, "")
end
