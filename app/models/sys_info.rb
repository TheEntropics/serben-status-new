class SysInfo < ActiveRecord::Base

	HISTORY_LIMIT = 100

	# Return the lasts HISTORY_LIMIT cpu records
	def self.cpu_history
		SysInfo.select(:cpu, :created_at).order(:created_at => :desc).limit(HISTORY_LIMIT)
	end

	# Return the lasts HISTORY_LIMIT ram records
	def self.ram_history
		SysInfo.select(:ram, :created_at).order(:created_at => :desc).limit(HISTORY_LIMIT)
	end

	# Return the lasts HISTORY_LIMIT rectords
	def self.history
		SysInfo.order(:created_at => :desc).limit(HISTORY_LIMIT)
	end
end
