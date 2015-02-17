class CreateServices < ActiveRecord::Migration
	def change
		create_table :services do |t|
			t.string :service
			t.boolean :status

			t.timestamps
		end
	end
end
