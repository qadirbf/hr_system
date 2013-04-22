class AddContactInfoToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :contact_demand_id, :integer
    add_column :orders, :contact_id, :integer
    add_index :orders, :contact_demand_id
    add_index :orders, :contact_id
  end

  def down
    remove_column :orders, :contact_demand_id
    remove_column :orders, :contact_id
  end
end
