#encoding:utf-8
class Order < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :firm
  belongs_to :employee
  has_many :share_orders

  validates_presence_of :total_amount, :message => "请输入订单金额！"

  STATUS = [["通过", 1], ["未通过", 2], ["未到账", 3], ["已到账", 4]]

  include HrLib::Functions

  def status_label
    get_array_type_text STATUS, self.status_id
  end

  def share_money(e_id)
    share_order = self.share_orders.select { |o| o.employee_id == e_id }.first
    share_order.try(:money).to_i
  end

  def share_detail
    share_orders = self.share_orders
    unless share_orders.blank?
      ary = []
      share_orders.each do |o|
        ary << [o.employee.username, "#{o.percentage}%", "#{o.money}元"].join(", ")
      end
      ary.join("<br/>").html_safe()
    else
      ""
    end
  end

end
