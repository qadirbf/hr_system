class AddAppInterviewDateToDailies < ActiveRecord::Migration
  def up
    add_column :dailies, :app_interview_date, :string
  end

  def down
    remove_column :dailies, :app_interview_date
  end
end
