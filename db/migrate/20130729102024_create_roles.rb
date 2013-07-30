class CreateRoles < ActiveRecord::Migration
  def up
    create_table "roles" do |t|
      t.string :name
    end
    # generate the join table

    Role.create(:id => 1, :name => "admin")
    Role.create(:id => 2, :name => "manager")
    Role.create(:id => 3, :name => "leader")
    Role.create(:id => 4, :name => "sales")
    Role.create(:id => 5, :name => "adviser")
  end

  def down
    drop_table :roles
  end
end
