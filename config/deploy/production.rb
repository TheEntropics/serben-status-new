set :deployer, 'deploy'

server 'vps.edo', user: fetch(:deployer), roles: %w{web app db}, primary: true


namespace :deploy do
	task :bootstrap do
	end
end

before 'deploy:bootstrap', 'app:install_deps'

before 'rvm1:install:rvm', 'app:update_rvm_key'

before 'deploy:bootstrap', 'rvm1:install:rvm'
before 'deploy:bootstrap', 'rvm1:install:ruby'
before 'deploy:bootstrap', 'rvm1:install:gems'
before 'deploy:bootstrap', 'app:remove_warning'

before :deploy, 'app:upload_shared'
after :deploy, 'db:create_user'
after 'db:create_user', 'db:config'
before 'deploy:migrate', 'db:setup'
after :deploy, 'nginx:config'