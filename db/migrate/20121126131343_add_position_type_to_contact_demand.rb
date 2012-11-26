class AddPositionTypeToContactDemand < ActiveRecord::Migration
  def up
    add_column :contact_demands, :position_type_text, :string
    add_column :contact_demands, :position_description, :string
  end

  def down
    remove_column :contact_demands, :position_type_text
    remove_column :contact_demands, :position_description
  end
end
