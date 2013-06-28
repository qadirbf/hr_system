class CreateDailies < ActiveRecord::Migration
  def up
    create_table :dailies do |t|
      t.string   :name
      t.integer  :obj_id
      t.string   :obj_name
      t.integer  :contact_id
      t.string   :notes, :limit => 600
      t.timestamps
    end
    add_index :dailies, :contact_id
  end

  def down
    drop_table :dailies
  end
end
