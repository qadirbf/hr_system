class CreateEmpMsgs < ActiveRecord::Migration
  def change
    create_table :emp_msgs do |t|
      t.integer :from_id
      t.integer :to_id
      t.string :to_names,:limit=>1000
      t.string :title,:limit=>1000
      t.string :content,:limit=>3000
      t.integer :viewed,:limit=>2
      t.string :url,:limit=>1000
      t.datetime :created_at
    end

    change_table :emp_msgs do |t|
      t.index :from_id,:name=>"emp_msg_form_id"
      t.index :to_id,:name=>"emp_msg_to_id"
      t.index :viewed,:name=>"emp_msg_viewed"
    end

  end
end
