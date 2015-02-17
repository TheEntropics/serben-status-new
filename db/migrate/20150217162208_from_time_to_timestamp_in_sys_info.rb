class FromTimeToTimestampInSysInfo < ActiveRecord::Migration
	def change
		change_column :sys_infos, :uptime, :timestamp
	end
end
