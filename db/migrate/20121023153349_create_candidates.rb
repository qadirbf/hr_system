class CreateCandidates < ActiveRecord::Migration
  def change
    create_table :candidates do |t|
      t.integer :contact_id
      t.integer :employee_id
      t.integer :grab_by
      t.datetime :grab_at
      t.timestamps
    end

    add_index :candidates, :contact_id
    add_index :candidates, :employee_id
    add_index :candidates, :grab_at
    add_index :candidates, :grab_by
    add_index :candidates, :created_at
    add_index :candidates, :updated_at
  end
end
