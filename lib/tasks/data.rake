require 'net/ping'
require 'net/http'
require 'nmap/program'
require 'nmap/xml'

host = '5.135.177.211'

namespace :data do

	desc 'Populate the database with a continous stream of data'
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

	desc 'Connect to the remote server and check its status'
	task :check => :environment do
		ping host
		sys_info host
		nmap host
	end

	def ping(host)
		Net::Ping::TCP.service_check = true

		t, up = time { Net::Ping::TCP.new(host).ping? }

		Ping.create!(ping: t*1000, up: up)
	rescue Exception => e
		puts "Error connecting to #{host}"
		puts e
		Ping.create!(ping: -1, up: false)
	end

	def sys_info(host)
		s = JSON.parse fetch('http://' + host + '/status-wrapper.php')

		SysInfo.create!(
			cpu: s['load'],
			ram: s['mem']['used'].to_f / s['mem']['total'].to_f,
			uptime: s['uptime']
		)
	rescue Exception => e
		puts "Error retriving sys_info!"
		puts e
	end

	def nmap(host)
		known_ports = {
			22 => 'ssh',
			21 => 'ftp',
			80 => 'http',
			110 => 'pop3',
			25 => 'smtp',
			143 => 'imap',
			3389 => 'rdp',
			8088 => 'forum',
			9091 => 'torrent',
			6800 => 'download',
			25565 => 'minecraft',
			25566 => 'minecraft_alt'
		}
		
		Nmap::Program.scan do |nmap|
			nmap.xml = 'tmp/scan.xml'
			nmap.verbose = false
			nmap

			nmap.ports = known_ports.keys
			nmap.targets = host
		end
		Nmap::XML.new('tmp/scan.xml') do |xml|
			xml.each_host do |h|
				h.each_port do |p|
					Service.create!(
						service: known_ports[p.number].humanize,
					    status: p.state.to_s == 'open'
					)
				end
			end
		end
	rescue Exception => e
		puts "Error while executing nmap"
		puts e
	end

	
	
	def time(*args)
		throw ArgumentError unless block_given?

		start = Time.now.to_f
		res = yield *args
		finish = Time.now.to_f

		return finish - start, res
	end

	def fetch(uri_str, limit = 10)
		raise ArgumentError, 'too many HTTP redirects' if limit == 0

		response = Net::HTTP.get_response(URI(uri_str))

		case response
			when Net::HTTPSuccess then
				response.body
			when Net::HTTPRedirection then
				location = response['location']
				fetch(location, limit - 1)
			else
				response.value
		end
	end
end
