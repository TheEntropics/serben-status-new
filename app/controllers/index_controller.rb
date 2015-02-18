require 'json'

class IndexController < ApplicationController
	include ActionView::Helpers::NumberHelper
	include ActionView::Helpers::DateHelper

	def index
		@sys_info = SysInfo.last
		@status = Ping.current_status
		@uptime = @sys_info.try(:uptime) || Time.now
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
			cpu: sys_info.cpu,
			ram: sys_info.ram,
			history: history.reverse_order.to_a,
			uptime: sys_info.uptime ? time_ago_in_words(sys_info.uptime) : 'unknown',
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
		Service.order(:created_at).group(:service)
	end
end
