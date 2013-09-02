#encoding:utf-8
class Order < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :firm
  belongs_to :employee
  belongs_to :contact_demand
  belongs_to :contact
  has_many :share_orders

  validates_presence_of :total_amount, :message => "请输入订单金额！"

  STATUS = [["未到账", 1], ["已到账", 2], ["补充招聘", 3]]

  include HrLib::Functions

  before_save :check_status

  def check_status
    if !self.credited_date.blank? && self.status_id != 3
      self.status_id = 2
    end
  end

  def status_label
    get_array_type_text STATUS, self.status_id
  end

  def share_money(e_id)
    share_order = self.share_orders.select { |o| o.employee_id == e_id }.first
    share_order.try(:money).to_i
  end

  def share_detail(user)
    share_orders = self.share_orders
    unless share_orders.blank?
      ary = []
      if user.is_admin?
        share_orders.each do |o|
          ary << [o.employee.username, "#{o.percentage}%", "#{o.money}元"].join(", ")
        end
      else
        share_orders.each do |o|
          ary << [o.employee.username, "#{o.percentage}%", "#{o.money}元"].join(", ") unless o.employee.is_admin?
        end
      end
      ary.join("<br/>").html_safe()
    else
      ""
    end
  end

  def position_and_contact
    [self.contact_demand.try(:position_type_text), self.try(:candidate_name)].delete_if{|a| a.blank?}.join(", ")
  end

  def show_notes
    adds = Order.where("add_to = #{self.id}").all || []
    h, ary = '', []
    adds.each do |a|
      ary << "<a href='/res/show_order/#{a.id}'>#{a.order_no}</a>"
    end
    h = ary.join(";").html_safe unless ary.blank?
    h = ("拥有补充订单如下：" + h) unless h.blank?
    tmp = [self.notes, h].delete_if{|a| a.blank?}
    tmp.join("<br/>").html_safe
  end

end
