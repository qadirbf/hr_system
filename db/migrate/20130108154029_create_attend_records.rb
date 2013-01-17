class CreateAttendRecords < ActiveRecord::Migration
  def up
    create_table :attend_records do |t|
      t.integer  :employee_id
      t.integer  :attend_type
      t.string   :ip
      t.datetime :record_time
      t.timestamps
    end

    add_index :attend_records, :employee_id
  end

  def down
    drop_table :attend_records
  end
end
