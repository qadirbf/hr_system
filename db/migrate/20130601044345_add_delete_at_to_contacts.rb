class AddDeleteAtToContacts < ActiveRecord::Migration
  def up
    add_column :contacts, :delete_at, :datetime
  end

  def down
    remove_column :contacts, :delete_at
  end
end
