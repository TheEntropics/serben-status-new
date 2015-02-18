# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server 'vps.edo', user: 'deploy', roles: %w{web app db}

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
			sudo 'apt-get install -y nmap nginx'
		end
	end
end

before 'rvm1:install:rvm', 'app:update_rvm_key'

before 'deploy', 'rvm1:install:rvm'
before 'deploy', 'rvm1:install:ruby'
before 'deploy', 'rvm1:install:gems'
before 'deploy', 'app:install_deps'
before 'deploy', 'app:remove_warning'

namespace :nginx do
	task :config do

	end
end