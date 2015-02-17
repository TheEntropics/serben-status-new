class CreateSysInfos < ActiveRecord::Migration
	def change
		create_table :sys_infos do |t|
			t.float :cpu
			t.float :ram
			t.time :uptime

			t.timestamps
		end
	end
end
