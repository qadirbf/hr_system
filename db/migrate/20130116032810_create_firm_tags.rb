class CreateFirmTags < ActiveRecord::Migration
  def up
    create_table :firm_tags do |t|
      t.integer  :firm_id
      t.integer  :tag_id
      t.timestamps
    end
    add_index :firm_tags, :firm_id
    add_index :firm_tags, :tag_id
  end

  def down
    drop_table :firm_tags
  end
end
