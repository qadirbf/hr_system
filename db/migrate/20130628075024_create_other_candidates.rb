class CreateOtherCandidates < ActiveRecord::Migration
  def change
    create_table :other_candidates do |t|
      t.string :name
      t.string :sex
      t.string :birth
      t.string :city
      t.integer :city_id
      t.integer :province_id
      t.string :hukou
      t.string :salary
      t.string :work_year
      t.string :address
      t.string :postcode
      t.string :email
      t.string :mobile
      t.string :home_tel
      t.string :work_tel
      t.string :industry
      t.string :location
      t.string :industry_code
      t.string :job_post
      t.string :website
      t.string :id_card
      t.string :education
      t.string :source
      t.text :remarks

      t.timestamps
    end

    add_index :other_candidates, :city_id
    add_index :other_candidates, :province_id
    add_index :other_candidates, :source
    add_index :other_candidates, :updated_at
    add_index :other_candidates, :created_at
  end
end
