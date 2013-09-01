class AddFartherToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :add_to, :integer     #补充某订单的ID
    add_column :orders, :count_in, :integer   #是否计入总额
  end

  def down
    remove_column :orders, :add_to
    remove_column :orders, :count_in
  end
end
