class AddPositionTypeToContacts < ActiveRecord::Migration
  def up
    add_column :contacts, :position_type, :string
  end

  def down
    remove_column :contacts, :position_type
  end
end
