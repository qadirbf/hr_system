#encoding:utf-8
class Firm < ActiveRecord::Base
  has_many :contacts, :dependent => :destroy
  has_many :recalls, :dependent => :destroy
  belongs_to :province
  belongs_to :city
  has_many :contact_demands, :dependent => :destroy
  has_many :firm_leads, :dependent => :destroy
  has_many :firm_cat_links, :dependent => :destroy
  has_many :firm_tags
  has_many :orders
  validates_presence_of :firm_name,:message=>"公司名字不能为空"
  validates_presence_of :province_id,:message=>"请选择省份"
  validates_presence_of :city_id,:message=>"请选择城市"
  validates_presence_of :firm_type_id,:message=>"请选择公司类型"

  FOREIGN_TYPES = [['内资',1],['外资',2]]
  RATING_TYPE = [["A+", 9], ["A", 8], ["B", 7], ["C", 6], ["D", 2]]

  include HrLib::Functions

  def rating_type
    get_array_type_text RATING_TYPE, self.rating
  end

  def is_followed_by?(user)
    !!FirmLead.first(:select=>"id",:conditions=>["firm_id=? and employee_id=?",self.id,user.id])
  end

  def sales_followed_by?(user)
    self.lead_by_id(1).employee_id==user.id
  end

  def res_followed_by?(user)
    self.lead_by_id(2).employee_id==user.id
  end

  def can_grab_by?(user)
    lead = self.lead_by_id(user.leads_type_id)
    lead.employee_id==0
  end

  def grab_by(user)
    user = Employee.find(user) unless user.is_a?(Employee)
    lead = self.lead_by_id(user.leads_type_id)
    lead.grab_by(user.id)
  end

  def lead_by_id(tid=1)
    FirmLead.first(:conditions=>["firm_id=? and leads_type_id=?",self.id,tid])||
        FirmLead.new(:firm_id=>self.id,:leads_type_id=>tid,:employee_id=>0)
  end

  def grab_user_info
    s = "销售部：#{self.lead_by_id(1).grab_user_info}<br>"
    s << "顾问部：#{self.lead_by_id(2).grab_user_info}"
    s.html_safe
  end

  def firm_categories
    self.firm_cat_links.map{|c| c.firm_category}
  end

end
