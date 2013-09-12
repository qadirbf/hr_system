class AddApproveAtToApplyLeaves < ActiveRecord::Migration
  def change
    add_column :apply_leaves, :approved_at, :datetime
  end
end
