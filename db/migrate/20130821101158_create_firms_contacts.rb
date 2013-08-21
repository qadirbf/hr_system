class CreateFirmsContacts < ActiveRecord::Migration
  def up
    create_table :firms_contacts do |t|
      t.integer  :firm_id
      t.integer  :uploaded_by
      t.string   :load_path
      t.timestamps
    end
    add_index    :firms_contacts, :firm_id
    add_index    :firms_contacts, :uploaded_by
  end

  def down
    drop_table  :firms_contacts
  end
end
