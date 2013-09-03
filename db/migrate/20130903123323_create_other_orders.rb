class CreateOtherOrders < ActiveRecord::Migration
  def up
    create_table :other_orders do |t|
      t.integer  :order_id
      t.integer  :added_order_id
      t.timestamps
    end
    add_index :other_orders, :order_id
    add_index :other_orders, :added_order_id
  end

  def down
    drop_table :other_orders
  end
end
