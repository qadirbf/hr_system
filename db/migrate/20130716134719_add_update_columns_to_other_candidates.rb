class AddUpdateColumnsToOtherCandidates < ActiveRecord::Migration
  def up
    add_column :other_candidates, :age, :integer
  end

  def down
    remove_column :other_candidates, :age
  end
end
