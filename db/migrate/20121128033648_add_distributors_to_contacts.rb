class AddDistributorsToContacts < ActiveRecord::Migration
  def up
    add_column :contacts, :distributors, :integer, :limit => 2
  end

  def down
    remove_column :contacts, :distributors
  end
end
