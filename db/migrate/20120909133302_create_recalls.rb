class CreateRecalls < ActiveRecord::Migration
  def change
    create_table :recalls do |t|
      t.integer :employee_id
      t.integer :firm_id
      t.integer :contact_id
      t.datetime :appt_date
      t.integer :contact_by_id,:limit=>2
      t.integer :stage_id,:limit=>2
      t.integer :important,:limit=>2
      t.string :notes,:limit=>3000
      t.datetime :completed_at
      t.integer :completed_by
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    change_table :recalls do |t|
      t.index :employee_id,:name=>"idx_recall_emp"
      t.index :firm_id,:name=>"idx_recall_firm"
      t.index :contact_id,:name=>"idx_recall_contact"
      t.index :appt_date,:name=>"idx_recall_appt_at"
      t.index :completed_at,:name=>"idx_recall_com_at"
    end

  end
end
