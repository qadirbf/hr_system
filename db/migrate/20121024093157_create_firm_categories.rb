#encoding: utf-8
class CreateFirmCategories < ActiveRecord::Migration
  def change
    create_table :firm_categories do |t|
      t.string :name
      t.timestamps
    end

    create_table :firm_cat_links do |t|
      t.integer :firm_id
      t.integer :firm_category_id
      t.timestamps
    end

    add_column :firms, :rating, :integer
    add_index :firms, :rating

    data = [[1, '结构'],[2, '建筑'],[3, '墙面材料'],[4, '地面材料'],[5, '室内材料'],[6, '室外设施'],[7, '建筑机械及设备'],[8, '工程软件'],[9, '暖通设备'],[10, '建筑给水排水设备'],[11, '建筑电气设备'],[12, '设计、施工及装修单位'],[13, '其他']]
    data.each do |d|
      c = FirmCategory.new(:name=>d[1])
      c.id = d[0]
      c.save
    end
  end
end
