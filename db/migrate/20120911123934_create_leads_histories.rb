class CreateLeadsHistories < ActiveRecord::Migration
  def change
    create_table :leads_histories do |t|
      t.integer :firm_id
      t.integer :leads_type_id,:liimt=>2
      t.integer :old_emp_id
      t.integer :employee_id
      t.datetime :grab_date
      t.datetime :expire_date
      t.integer :ext,:limit=>3
      t.integer :created_by
      t.datetime :created_at
    end

    change_table :leads_histories do |t|
      t.index :firm_id,:name=>"idx_lead_his_firm"
      t.index :leads_type_id,:name=>"idx_lead_his_type"
      t.index :old_emp_id,:name=>"idx_lead_his_old_emp"
      t.index :employee_id,:name=>"idx_lead_his_emp"
    end

  end
end
