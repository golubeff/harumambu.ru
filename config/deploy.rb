set :application, "hara"
set :repository,  "git@github.com:golubeff/harumambu.ru.git"

set :deploy_to, "/home/hara/production"

#set :deploy_to, "/home/golubeff/travel_portal"
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :keep_releases, 2
role :web, "hara@harumambu.ru"                          # Your HTTP server, Apache/etc
role :app, "hara@harumambu.ru"                          # This may be the same as your `Web` server
role :db,  "hara@harumambu.ru", :primary => true # This is where Rails migrations will run
set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

after "deploy:symlink", "deploy:config"
after "deploy:symlink", "deploy:migrate"
after "deploy:restart", "deploy:cleanup"
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    #run "cd #{current_path} && ./script/grabber.rb stop && sleep 10 && ./script/grabber.rb start"
    run "thin stop -C #{current_path}/config/thin.yml && thin start -C #{current_path}/config/thin.yml"
  end
  task :config do
    run "cd #{current_path}/config/ && ln -s #{shared_path}/config/* ."
  end
end

namespace :rake do
  task :invoke do
    if ENV['COMMAND'].to_s.strip == ''
      puts "USAGE:   cap rake:invoke COMMAND='db:migrate'"
    else
      run "cd #{current_path} && rake #{ENV['COMMAND']}"
    end
  end
end


