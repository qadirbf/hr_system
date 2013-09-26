class AddQqToDailies < ActiveRecord::Migration
  def change
    add_column :dailies, :qq, :string
  end
end
