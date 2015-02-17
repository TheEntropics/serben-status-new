class RemoveUpdateAt < ActiveRecord::Migration
    def change
        remove_column :sys_infos, :updated_at
        remove_column :logs, :updated_at
        remove_column :pings, :updated_at
        remove_column :services, :updated_at
    end
end
