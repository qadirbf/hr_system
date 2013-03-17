class CreateOrders < ActiveRecord::Migration
  def up
    create_table :orders do |t|
      t.integer  :firm_id
      t.integer  :employee_id
      t.float    :total_amount
      t.date     :credited_date  # 到账日期
      t.integer  :status_id   # 状态
      t.string   :notes, :limit => 1000
      t.timestamps
    end
    add_index :orders, :firm_id
    add_index :orders, :status_id
    add_index :orders, :employee_id
  end

  def down
    drop_table :orders
  end
end
