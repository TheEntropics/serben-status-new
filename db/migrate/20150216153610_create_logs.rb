class CreateLogs < ActiveRecord::Migration
	def change
		create_table :logs do |t|
			t.integer :level
			t.string :title
			t.text :message

			t.timestamps
		end
	end
end
