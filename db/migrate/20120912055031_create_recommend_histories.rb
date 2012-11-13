class CreateRecommendHistories < ActiveRecord::Migration
  def change
    create_table :recommend_histories do |t|
      t.integer :employee_id
      t.integer :contact_id
      t.integer :firm_id
      t.integer :contact_demand_id
      t.integer :status_id,:limit=>2
      t.integer :sales_id
      t.string :notes,:limit=>3000
      t.datetime :interview_date
      t.datetime :feedback_date
      t.string :feedback_notes,:limit=>3000
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    change_table :recommend_histories do |t|
      t.index :employee_id,:name=>"idx_rec_his_emp"
      t.index :contact_id,:name=>"idx_rec_his_contact"
      t.index :firm_id,:name=>"idx_rec_his_firm"
      t.index :contact_demand_id,:name=>"idx_rec_his_demand"
    end

  end
end
