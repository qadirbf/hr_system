class CreateEmployeesFirmTypes < ActiveRecord::Migration
  def up
    create_table :employees_firm_types do |t|
      t.integer  :employee_id
      t.integer  :firm_type_id
      t.timestamps
    end
    add_index :employees_firm_types, :employee_id
    add_index :employees_firm_types, :firm_type_id
  end

  def down
    drop_table :employees_firm_types
  end

end
