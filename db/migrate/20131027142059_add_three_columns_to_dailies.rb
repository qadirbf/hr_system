class AddThreeColumnsToDailies < ActiveRecord::Migration
  def change
    add_column :dailies, :want_new_job, :integer
    add_column :dailies, :set_contact_candidate, :integer
    add_column :dailies, :salary_notes, :string
  end
end
