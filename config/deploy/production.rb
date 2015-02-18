set :deployer, 'deploy'

server 'vps.edo', user: fetch(:deployer), roles: %w{web app db}, primary: true

namespace :app do
	task :update_rvm_key do
		on roles(:all) do
			execute :gpg, '--keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3'
		end
	end

	task :remove_warning do
		on roles(:all) do
			execute :rvm, 'rvmrc warning ignore allGemfiles'
		end
	end

	task :install_deps do
		on roles(:app) do
			sudo 'apt-get update'
			sudo 'apt-get install -y nmap nginx postgresql postgresql-common postgresql-9.3 libpq-dev'
		end
	end

	task :upload_shared do
		on roles(:all) do
			puts shared_path
			upload! 'config/shared/', shared_path, recursive: true
			puts shared_path
			execute :mv, "#{shared_path}/shared/* #{shared_path}/"
			puts shared_path
		end
	end

	task :generate_secrets do
		on roles(:app) do
			within release_path do
				# noinspection RubyArgCount
				with rails_env: fetch(:rails_env) do
					production = capture(:rake, 'secret')
					development = capture(:rake, 'secret')
					test = capture(:rake, 'secret')
					info "The production secret is '#{production}'"
					info "The development secret is '#{development}'"
					info "The test secret is '#{test}'"
					secrets =  "production: \n"
					secrets += " secret_key_base: #{production} \n"
					secrets += "development: \n"
					secrets += " secret_key_base: #{development} \n"
					secrets += "test: \n"
					secrets += " secret_key_base: #{test} \n"

					execute :echo, "-e '#{secrets}' > #{release_path}/config/secrets.yml"
				end
			end
		end
	end
end

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

namespace :nginx do
	task :config do
		on roles(:web) do
			sudo :rm, '-f /etc/nginx/sites-enabled/default'
			sudo :rm, "-f /etc/nginx/sites-enabled/#{fetch :application}"
			sudo :ln, "-s #{shared_path}/nginx.conf /etc/nginx/sites-enabled/#{fetch :application}"
			sudo :service, 'nginx reload'
		end
	end
end

namespace :db do
	task :create_user do
		on roles(:db) do
			as 'postgres' do
				unless execute :createuser, "-d #{fetch :deployer}", raise_on_non_zero_exit: false
					warn "The role '#{fetch :deployer}' cannot be created"
				end
			end
		end
	end

	task :config do
		on roles(:db) do
			as 'root' do
				# noinspection RubyArgCount
				v = capture(:cat, "/etc/postgresql/9.3/main/pg_hba.conf | grep \"local\\sall\\s#{fetch :deployer}\\strust\"", raise_on_non_zero_exit: false)
				if v.empty?
					execute :echo, "local all #{fetch :deployer} trust >> /etc/postgresql/9.3/main/pg_hba.conf"
				else
					warn 'DB alreay configured'
				end
			end
		end
	end

	task :setup do
		on roles(:db) do
			within release_path do
				with rails_env: fetch(:rails_env) do
					execute :rm, "-f #{release_path}/config/database.yml"
					execute :ln, "#{shared_path}/database.yml #{release_path}/config/database.yml"
					rake 'db:setup'
				end
			end
		end
	end
end

before :deploy, 'app:upload_shared'
after :deploy, 'db:create_user'
after 'db:create_user', 'db:config'
before 'deploy:migrate', 'db:setup'
after :deploy, 'nginx:config'