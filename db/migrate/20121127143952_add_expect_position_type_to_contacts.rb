class AddExpectPositionTypeToContacts < ActiveRecord::Migration
  def up
    add_column :contacts, :expect_position_type, :string
  end

  def down
    remove_column :contacts, :expect_position_type
  end
end
