class FirmCatLink < ActiveRecord::Base

  belongs_to :firm
  belongs_to :firm_category

end
