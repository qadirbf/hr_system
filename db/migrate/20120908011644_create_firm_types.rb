class CreateFirmTypes < ActiveRecord::Migration
  def change
    create_table :firm_types do |t|
      t.string :name
    end
  end
end
