server 'build02', user: 'deploy', roles: %w{app db web}

set :branch, 'master'
set :deploy_to, '/var/www/rate-service'
set :puma_bind, 'tcp://0.0.0.0:4568'
set :rack_env, :production
