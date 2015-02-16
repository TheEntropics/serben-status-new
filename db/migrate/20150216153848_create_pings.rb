class CreatePings < ActiveRecord::Migration
  def change
    create_table :pings do |t|
      t.boolean :up
      t.integer :ping

      t.timestamps
    end
  end
end
