#encoding:utf-8
class Order < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :firm
  belongs_to :employee
  belongs_to :contact_demand
  belongs_to :contact
  has_many :share_orders
  has_many :other_orders

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
    [self.contact_demand.try(:position_type_text), self.try(:candidate_name)].delete_if { |a| a.blank? }.join(", ")
  end

  def show_other_orders
    a = self.other_orders || []
    a.collect(&:added_order_id).join(',')
  end

  def show_notes
    r = []
    if self.status_id == 3 # 该订单是补充订单
      ary = OtherOrder.where("added_order_id = #{self.id}").all || []
      ary.each do |a|
        r << "<a href='/res/show_order/#{a.order_id}'>#{a.order_id}</a>&nbsp;"
      end
      h = r.join(";") unless r.blank?
      h = ("该订单是以下订单的补充：" + h) unless h.blank?
    else # 该订单是普通订单
      ary = self.other_orders || []
      ary.each do |a|
        r << "<a href='/res/show_order/#{a.added_order_id}'>#{a.added_order_id}</a>&nbsp;"
      end
      h = r.join(";") unless r.blank?
      h = ("拥有补充订单如下：" + h) unless h.blank?
    end
    tmp = [self.notes, h].delete_if { |a| a.blank? }
    tmp.join("<br/>").html_safe
  end

end
