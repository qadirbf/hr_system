class CreateAttendChecks < ActiveRecord::Migration
  def self.up
    create_table :attend_checks do |t|
      t.integer :attendance_id
      t.integer :apply_leave_id
      t.integer :employee_id
      t.integer :notice_count, :limit => 2
      t.integer :active, :limit => 2
      t.timestamps
    end

    change_table :attend_checks do |t|
      t.index :attendance_id, :name => "attend_check_attend"
      t.index :apply_leave_id, :name => "attend_check_apply"
      t.index :employee_id, :name => "attend_check_emp"
    end

  end

  def self.down
    drop_table :attend_checks
  end
end
