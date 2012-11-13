class CreateContactPositions < ActiveRecord::Migration
  def change
    create_table :contact_positions do |t|
      t.string :name
      t.integer :firm_type_id
    end

    change_table :contact_positions do |t|
      t.index :firm_type_id,:name=>"idx_position_firm_type"
    end
  end
end
