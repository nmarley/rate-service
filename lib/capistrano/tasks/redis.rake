namespace :redis do
  %w[ start stop restart status ].each do |command|
    desc "#{command} redis"
    task command.to_sym do
      on roles(:web) do
        execute "systemctl #{command} redis"
      end
    end
  end

  desc "load redis"
  task :load do
    on roles(:web) do
      #execute "cd #{release_path}; bundle exec rake -Rlib/tasks redis:populate"
      within release_path do
        with rack_env: "#{fetch(:production)}" do
          execute "bundle exec rake -Rlib/tasks redis:populate"
        end
      end
    end
  end
end

