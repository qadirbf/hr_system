class AddColumnToAttendances < ActiveRecord::Migration
  def up
    add_column :attendances, :start_time, :datetime
    add_column :attendances, :end_time, :datetime
    add_column :attendances, :start_ip, :string
    add_column :attendances, :end_ip, :string
    add_column :attendances, :absence, :integer
  end

  def down
    remove_column :attendances, :start_time
    remove_column :attendances, :start_ip
    remove_column :attendances, :end_time
    remove_column :attendances, :end_ip
    remove_column :attendances, :absence
  end
end
