class CreateConstructionAreas < ActiveRecord::Migration
  def change
    create_table :construction_areas do |t|
      t.string :name
    end
  end
end
