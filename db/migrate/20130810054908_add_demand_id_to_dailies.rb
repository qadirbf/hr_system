class AddDemandIdToDailies < ActiveRecord::Migration
  def up
    add_column :dailies, :demand_id, :integer
    add_index :dailies, :demand_id
  end

  def down
    remove_column :dailies, :demand_id
  end
end
