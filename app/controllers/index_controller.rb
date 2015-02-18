require 'json'

class IndexController < ApplicationController
	include ActionView::Helpers::NumberHelper
	include ActionView::Helpers::DateHelper

	def index
		@sys_info = SysInfo.last
		@status = Ping.current_status
		@uptime = @sys_info.try(:uptime) || nil
		@availability = Ping.availability
		@logs = Log.all
		@services = services
		@cpu_history = SysInfo.cpu_history
		@ram_history = SysInfo.ram_history
	end

	def data
		history = SysInfo.history
		log = Log.all

		sys_info = SysInfo.last

		if params['since']
			since = Time.parse params['since']

			history = history.where('created_at >= ?', since)
			log = log.where('created_at >= ?', since)
		end

		data = {
			server_up: Ping.current_status,
			availability: number_to_percentage(Ping.availability*100),
			services: services,
			cpu: sys_info.try(:cpu, 0),
			ram: sys_info.try(:ram, 0),
			history: history.reverse_order.to_a,
			uptime: sys_info.try(:uptime, nil) ? time_ago_in_words(sys_info.uptime) : 'unknown',
			log: log,
			update: Time.now
		}
		data[:since] = params['since'] if params['since']

		respond_to do |format|
			format.json { render json: data }
			format.html { render text: '<pre>' + JSON.pretty_generate(data) }
		end
	end

	protected

	def services
		# services = Service.select(:service).group(:service)
		# Service.order(:created_at).where(service: services)
		data = Service.select('*, row_number() over (partition by service order by created_at desc) as row_number').to_sql
		Service.select('*').from("(#{data}) as row").where('row_number = 1')
	end
end
