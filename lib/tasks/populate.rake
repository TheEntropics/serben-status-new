require 'pp'

task :populate => :environment do
	start = Time.now
	cpu = 0.5
	ram = 0.5

	services = Service.select(:service).distinct.to_a.map { |s| s.service }
	puts services

	while true
		cpu += rand - 0.5
		ram += rand - 0.5

		cpu /= 2 if cpu > 1.2
		ram /= 2 if ram > 1.2
		cpu += 0.5 if cpu < 0.1
		ram += 0.5 if ram < 0.1

		sys_info = SysInfo.create cpu: cpu, ram: ram, uptime: start
		ping = Ping.create ping: rand(20), up: rand > 0.05
		services.each do |service|
			s = Service.create service: service, status: rand > 0.5
			puts s.attributes.slice('id', 'service', 'status')
		end

		puts sys_info.attributes.slice('id', 'cpu', 'ram')
		puts ping.attributes.slice('id', 'ping', 'up')
		sleep 7
	end
end
