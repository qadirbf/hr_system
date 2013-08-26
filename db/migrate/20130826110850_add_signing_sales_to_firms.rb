class AddSigningSalesToFirms < ActiveRecord::Migration
  def change
    add_column :firms, :signing_sales, :integer
  end
end
