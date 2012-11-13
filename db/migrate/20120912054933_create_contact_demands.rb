class CreateContactDemands < ActiveRecord::Migration
  def change
    create_table :contact_demands do |t|
      t.integer :firm_id
      t.integer :employee_id    #负责顾问
      t.integer :firm_type_id
      t.integer :position_type_id
      t.integer :status_id,:limit=>2
      t.integer :salary_type_id,:limit=>2
      t.string :salary_value
      t.string :salary_notes,:limit=>2000
      t.integer :province_id
      t.integer :city_id
      t.string :work_place
      t.integer :contact_num,:limit=>5
      t.string :demand_notes,:limit=>3000
      t.integer :need_ad_recruit,:limit=>2
      t.string :ad_recruit_notes,:limit=>3000
      t.string :sales_notes,:limit=>3000
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    change_table :contact_demands do |t|
      t.index :firm_id,:name=>"idx_demand_firm"
      t.index :employee_id,:name=>"idx_demand_emp"
      t.index :firm_type_id,:name=>"idx_demand_firm_type"
      t.index :position_type_id,:name=>"idx_demand_pos_type"
      t.index :province_id,:name=>"idx_demand_province"
      t.index :city_id,:name=>"idx_demand_city"
    end

  end
end
