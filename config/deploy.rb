# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'rate-service'
set :repo_url, 'https://github.com/nmarley/rate-service.git'

# ensure that shared/tmp/pids and shared/log are created
append :linked_dirs, 'tmp/pids', 'log'

# Default value for :scm is :git
set :scm, :git
