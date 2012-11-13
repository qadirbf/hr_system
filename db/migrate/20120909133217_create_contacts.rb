class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :firm_id
      t.string :first_name
      t.string :last_name
      t.string :salutation
      t.string :position
      t.integer :sex,:limit=>2
      t.integer :age,:limit=>3
      t.datetime :birthday
      t.integer :work_year,:limit=>3
      t.datetime :start_work_date
      t.integer :resigned,:limit=>2
      t.integer :want_new_job,:limit=>2
      t.string :phone
      t.string :phone_ext,:limit=>100
      t.string :mobile
      t.string :email
      t.string :fax
      t.string :postcode,:limit=>30
      t.integer :country_id
      t.integer :province_id
      t.integer :city_id
      t.string :address,:limit=>1000
      t.string :address2,:limit=>1000
      t.integer :address_same_as_firm,:limit=>2
      t.integer :contact_no_same_as_firm,:limit=>2
      t.integer :firm_type_id
      t.integer :position_type_id
      t.integer :expect_firm_type_id
      t.integer :expect_position_type_id
      t.string :expect_prof_notes,:limit=>3000
      t.string :expect_work_place,:limit=>2000
      t.integer :expect_salary,:limit=>2
      t.string :salary_notes,:limit=>3000
      t.string :notes,:limit=>3000
      t.integer :status_id,:limit=>2
      t.integer :employee_id
      t.string :resume_file,:limit=>500
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    change_table :contacts do |t|
      t.index :firm_id,:name=>"idx_ctc_firm"
      t.index :employee_id,:name=>"idx_ctc_emp"
      t.index :status_id,:name=>"idx_ctc_status"
      t.index :created_by,:name=>"idx_ctc_create_user"
      t.index :updated_by,:name=>"idx_ctc_update_user"
      t.index :province_id,:name=>"idx_ctc_province"
      t.index :city_id,:name=>"idx_ctc_city"
      t.index :created_at,:name=>"idx_ctc_created_at"
      t.index :updated_at,:name=>"idx_ctc_updated_at"
    end

  end
end
