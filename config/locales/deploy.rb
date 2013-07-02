set :application, "panama"
set :repository, "git@github.com:wanliu/Panama.git"

set :user, "root"
set :password, "321654"
set :domain, "162.168.2.28"


default_run_options[:pty] = true
set :use_sudo,false
set :scm,"git"
set :scm_user,"root"
set :scm_passphrase,"321654"
set :deploy_to,     "/var/www/#{application}"
set :rails_env,     'production'
set :branch, "master"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

set :rvm_path, "/usr/local/rvm"
set :rvm_bin_path, "/usr/local/rvm/bin"
set :rvm_ruby_string, 'ruby-1.9.3'

require 'rvm/capistrano'
require "bundler/capistrano"

before 'deploy:setup' do
  run 'echo insecure > ~/.curlrc', :shell => 'bash -c'
  find_and_execute_task "rvm:install_rvm"
  find_and_execute_task 'rvm:install_ruby'
end

task :init_configure_path, :roles => :app do
  run "ln -sf #{deploy_to}/shared/config/sso.yml #{deploy_to}/current/config/sso.yml"
  run "ln -sf #{deploy_to}/shared/config/email.yml #{deploy_to}/current/config/email.yml"
  run "ln -sf #{deploy_to}/shared/config/application.yml #{deploy_to}/current/config/application.yml"
  run "ln -sf #{deploy_to}/shared/uploads #{deploy_to}/current/public/uploads"
  run "ln -sf #{deploy_to}/shared/config/switch_carrierwave.yml #{deploy_to}/current/config/switch_carrierwave.yml"
  run "ln -sf #{deploy_to}/shared/config/database.yml #{deploy_to}/current/config/database.yml"
end

namespace :db do
  task :seeds, :roles => :app do
    run "cd #{deploy_to}/current rake db:seeds RAILS_ENV=production"
  end
end


after "deploy:finalize_update", "deploy:symlink", :init_configure_path, "deploy:migrate"
load 'deploy/assets'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end