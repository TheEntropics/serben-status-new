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
