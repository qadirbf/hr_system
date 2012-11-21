class AddContractEndDateToRecommendHistory < ActiveRecord::Migration
  def up
    add_column :recommend_histories, :contract_end_date, :datetime
  end

  def down
    remove_column :recommend_histories, :contract_end_date
  end
end
