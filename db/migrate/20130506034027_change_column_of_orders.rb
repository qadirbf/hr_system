class ChangeColumnOfOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :contact_id
    add_column :orders, :candidate_name, :string
  end

  def down
    remove_column :orders, :candidate_name
    add_column :orders, :contact_id, :integer
  end
end
