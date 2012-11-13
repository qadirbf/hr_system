class CreateLoginHistories < ActiveRecord::Migration
  def change
    create_table :login_histories do |t|
      t.string :username
      t.integer :employee_id
      t.integer :failed,:limit=>2
      t.integer :click_count
      t.string :ip,:limit=>100
      t.string :session_id,:limit=>100
      t.string :pwd,:limit=>100
      t.datetime :created_at
    end

    change_table :login_histories do |t|
      t.index :username,:name=>"login_his_user"
      t.index :failed,:name=>"login_his_failed"
      t.index :created_at,:name=>"login_his_time"
    end

  end
end
