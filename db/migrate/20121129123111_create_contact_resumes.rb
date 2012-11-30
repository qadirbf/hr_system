class CreateContactResumes < ActiveRecord::Migration
  def up
    create_table :contact_resumes do |t|
      t.integer :contact_id
      t.integer :upload_by
      t.string  :load_path
      t.timestamps
    end
    add_index :contact_resumes, :contact_id
    add_index :contact_resumes, :upload_by
  end

  def down
    drop_table :contact_resumes
  end
end
