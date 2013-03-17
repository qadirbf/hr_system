#encoding:utf-8
class Order < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :firm
  belongs_to :employee

  validates_presence_of :total_amount, :message => "请输入订单金额！"

  STATUS = [["通过", 1], ["未通过", 2]]

  def status_label
    get_array_type_text STATUS, self.status
  end

end
