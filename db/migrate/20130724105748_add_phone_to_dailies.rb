class AddPhoneToDailies < ActiveRecord::Migration
  def up
    add_column :dailies, :phone, :string
  end

  def down
    remove_column :dailies, :phone
  end

end
