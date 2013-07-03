class AddColumnsToDailies < ActiveRecord::Migration
  def up
    add_column :dailies, :firm_name, :string
    add_column :dailies, :contact_name, :string
    add_column :dailies, :created_by, :integer
    add_column :dailies, :updated_by, :integer
  end

  def down
    remove_column :dailies, :firm_name
    remove_column :dailies, :contact_name
    remove_column :dailies, :created_by
    remove_column :dailies, :updated_by
  end
end
