class CreateAttendances < ActiveRecord::Migration
  def up
    create_table :attendances do |t|
      t.integer  :employee_id
      t.date     :this_date
      t.integer  :holiday, :limit => 2
      t.string   :real_start_time
      t.string   :real_end_time
      t.integer  :edit_by
      t.date     :edit_time
      t.integer  :early
      t.integer  :late
      t.integer  :absence_reason
      t.timestamps
    end
  end
end
