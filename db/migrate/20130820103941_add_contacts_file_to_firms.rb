class AddContactsFileToFirms < ActiveRecord::Migration
  def up
    add_column :firms, :contacts_file, :string
  end

  def down
    remove_column :firms, :contacts_file
  end
end
