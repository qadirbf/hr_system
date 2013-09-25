class AddQqToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :qq, :string
  end
end
