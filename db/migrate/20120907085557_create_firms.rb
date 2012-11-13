class CreateFirms < ActiveRecord::Migration
  def change
    create_table :firms do |t|
      t.string :firm_name
      t.integer :country_id
      t.integer :province_id
      t.integer :city_id
      t.integer :foreign_type_id,:limit=>2
      t.integer :firm_type_id,:limit=>2
      t.string :address
      t.string :address2
      t.string :postcode,:limit=>100
      t.string :phone
      t.string :fax
      t.string :email,:limit=>100
      t.string :website
      t.string :notes,:limit=>3000
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    change_table :firms do |t|
      t.index :country_id,:name=>"idx_firm_country"
      t.index :province_id,:name=>"idx_firm_provn"
      t.index :city_id,:name=>"idx_firm_city"
      t.index :foreign_type_id,:name=>"idx_firm_foreign"
      t.index :firm_type_id,:name=>"idx_firm_type"
      t.index :created_by,:name=>"idx_firm_cuser"
      t.index :updated_by,:name=>"idx_firm_uuser"
    end

  end
end
