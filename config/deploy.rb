set :application, "panama"
set :repository, "git@github.com:wanliu/panama.git"

set :user, "root"
set :password, "asdfasdf"
set :domain, "192.168.2.62"


default_run_options[:pty] = true
set :use_sudo,false
set :scm,"git"
set :scm_user,"root"
set :scm_passphrase,"123456"
set :deploy_to,     "/var/www/#{application}"
set :rails_env,     'production'

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