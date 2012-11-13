#encoding: utf-8
class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
    end

    Department.create([{:name=>"销售部"},{:name=>"顾问部"}])
  end
end
