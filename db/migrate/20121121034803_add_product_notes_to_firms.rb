class AddProductNotesToFirms < ActiveRecord::Migration
  def up
    add_column :firms, :product_notes, :string, :limit => 2000
  end

  def down
    remove_column :firms, :product_notes
  end
end
