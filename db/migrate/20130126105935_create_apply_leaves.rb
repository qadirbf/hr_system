class CreateApplyLeaves < ActiveRecord::Migration
  def self.up
    create_table :apply_leaves do |t|
      t.integer :employee_id
      t.integer :absence_reason,:limit => 3
      t.float :leave_time
      t.datetime :start_date
      t.datetime :end_date
      t.integer :status,:limit=>3
      t.integer :apply_to
      t.integer :updated_by
      t.integer :created_by
      t.string :manager_notes,:limit=>2000
      t.string :leave_notes,:limit=>2000
      t.string :deponent
      t.string :attachment
      t.integer :feed_type
      t.integer :apply_to_hr, :limit => 3
      t.string  :hr_notes, :limit => 1000
      t.integer :apply_cancel
      t.string  :cancel_reason, :limit => 1000
      t.string  :back_reason, :limit => 500
      t.timestamps
    end
    add_index :apply_leaves, :employee_id
    add_index :apply_leaves, :apply_to
  end

  def self.down
    drop_table :apply_leaves
  end
end
