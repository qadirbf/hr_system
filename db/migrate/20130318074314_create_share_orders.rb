class CreateShareOrders < ActiveRecord::Migration
  def up
    create_table :share_orders do |t|
      t.integer  :order_id
      t.integer  :employee_id
      t.integer  :percentage
      t.integer  :created_by
      t.integer  :updated_by
      t.float    :money
      t.timestamps
    end
    add_index  :share_orders, :order_id
    add_index  :share_orders, :employee_id
    add_index  :share_orders, :created_by
    add_index  :share_orders, :updated_by
  end

  def down
    drop_table :share_orders
  end
end
