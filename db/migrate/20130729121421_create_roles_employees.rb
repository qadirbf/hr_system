class CreateRolesEmployees < ActiveRecord::Migration
  def up
    create_table :roles_employees do |t|
      t.integer "role_id", "employee_id"
    end
    add_index "roles_employees", "role_id"
    add_index "roles_employees", "employee_id"

    admin = Employee.find_by_username("admin")
    role = Role.find_by_name("admin")
    RolesEmployee.create({:employee_id => admin.id, :role_id => role.id})
  end

  def down
    drop_table :roles_employees
  end
end
