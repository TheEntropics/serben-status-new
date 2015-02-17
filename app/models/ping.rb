class Ping < ActiveRecord::Base

	# Extract the status of the server
	# @return [boolean] True if the server last seen is online
	def self.current_status
		Ping.last && Ping.last.up
	end

	# Compute the System Availability
	# @return [float] 0.0~1.0 Value of success_ping/total_ping
	def self.availability
		Ping.where(up: true).count.to_f / Ping.count
	end

	def self.availability_success
		Ping.where(up: true).count
	end
end
