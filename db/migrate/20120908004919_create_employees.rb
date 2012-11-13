class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :username,:limit=>100
      t.string :name_cn,:limit=>100
      t.string :hashed_password
      t.string :salt
      t.integer :active,:limit=>2
      t.integer :department_id
      t.string :email
      t.string :phone,:limit=>50
      t.string :phone_ext,:limit=>50
      t.string :mobile,:limit=>50
      t.string :fax,:limit=>50
      t.string :encode
      t.datetime :join_date
      t.datetime :leave_date
      t.datetime :leave_reason
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    change_table :employees do |t|
      t.index :active,:name=>"idx_emp_active"
    end

  end
end
