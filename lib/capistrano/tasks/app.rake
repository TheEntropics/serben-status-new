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