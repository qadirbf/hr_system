class AddContractDate < ActiveRecord::Migration
  def up

    add_column :contact_demands, :contract_start, :datetime
    add_column :contact_demands, :contract_end, :datetime
    add_column :contact_demands, :is_pay, :integer
    add_column :contact_demands, :order_income, :integer

  end

  def down

    remove_column contact_demands, :contract_start
    remove_column contact_demands, :contract_end
    remove_column contact_demands, :is_pay
    remove_column contact_demands, :order_income

  end
end
