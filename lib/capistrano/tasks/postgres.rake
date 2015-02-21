namespace :db do
	task :create_user do
		on roles(:db) do
			as 'postgres' do
				unless execute :createuser, "-d -S -R #{fetch :deployer}", raise_on_non_zero_exit: false
					warn "The role '#{fetch :deployer}' cannot be created"
				end
			end
		end
	end

	task :config do
		on roles(:db) do
			as 'root' do
				v = capture(:cat, "/etc/postgresql/9.1/main/pg_hba.conf | grep \"local\\sall\\s#{fetch :deployer}\\strust\"", raise_on_non_zero_exit: false)
				if v.empty?
					execute :echo, "local all #{fetch :deployer} trust >> /etc/postgresql/9.1/main/pg_hba.conf"
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
