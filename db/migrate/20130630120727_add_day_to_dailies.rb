class AddDayToDailies < ActiveRecord::Migration
  def up
    add_column :dailies, :day, :date
  end

  def down
    remove_column :dailies, :day
  end
end
