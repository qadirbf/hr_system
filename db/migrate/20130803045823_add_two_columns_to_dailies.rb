class AddTwoColumnsToDailies < ActiveRecord::Migration
  def up
    add_column :dailies, :completed_flag, :integer
    add_column :dailies, :position_cn, :string
    add_column :dailies, :recall_id, :integer
  end

  def down
    remove_column :dailies, :completed_flag
    remove_column :dailies, :position_cn
    remove_column :dailies, :recall_id
  end
end
