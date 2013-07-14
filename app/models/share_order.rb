#encoding:utf-8
class ShareOrder < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :order
  belongs_to :employee

  #业绩金额
  def duty_count
    (self.percentage / 8.0) * self.order.total_amount
  end

end
