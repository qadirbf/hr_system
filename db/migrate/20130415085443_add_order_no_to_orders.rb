class AddOrderNoToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :order_no, :string
  end

  def down
    remove_column :orders, :order_no
  end
end
