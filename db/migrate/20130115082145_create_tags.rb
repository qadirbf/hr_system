class CreateTags < ActiveRecord::Migration
  def up
    create_table :tags do |t|
      t.string   :name
      t.integer  :firm_id
      t.integer  :created_by
      t.integer  :updated_by
      t.timestamps
    end
    add_index :tags, :firm_id
    add_index :tags, :created_by
  end

  def down
    drop_table :tags
  end
end
