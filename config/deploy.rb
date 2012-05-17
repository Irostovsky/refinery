require 'bundler/capistrano'
require "rvm/capistrano"

load 'deploy/assets'

set :user, 'ubuntu'

server '107.21.242.229', :app, :web, :primary => true

set :rvm_ruby_string, '1.9.3@refinery'

set :application, :refinery
set :scm, :git

set :deploy_to, "/var/www/apps/refinery"

set :repository,  "git@github.com:Irostovsky/refinery.git"

set :deploy_via, :copy
set :copy_strategy, :export

set :use_sudo, false

namespace :deploy do

  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end

