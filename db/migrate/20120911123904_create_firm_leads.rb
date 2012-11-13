class CreateFirmLeads < ActiveRecord::Migration
  def change
    create_table :firm_leads do |t|
      t.integer :firm_id
      t.integer :employee_id
      t.integer :leads_type_id,:liimt=>2
      t.integer :sales_stage_id,:limit=>2
      t.datetime :grab_date
      t.datetime :expire_date
      t.integer :ext,:limit=>3
      t.datetime :ext_at
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    change_table :firm_leads do |t|
      t.index :firm_id,:name=>"idx_lead_firm"
      t.index :employee_id,:name=>"idx_lead_emp"
      t.index :leads_type_id,:name=>"idx_lead_type"
    end

  end
end
