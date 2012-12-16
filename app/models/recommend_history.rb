#encoding:utf-8
class RecommendHistory < ActiveRecord::Base
  belongs_to :firm
  belongs_to :contact
  belongs_to :contact_demand
  belongs_to :updated_user, :class_name => "Employee", :foreign_key => 'updated_by'
  before_save :valid_record, :check_status
  after_create :change_record

  validates_presence_of :notes, :message => "请填写推荐备注！"
  validates_presence_of :feedback_date, :message => "请填写反馈时间！"
  attr_accessor :ret_id

  STATUS = [['推荐', 1], ['销售已接受', 2], ['已面试', 3], ['已拒绝', 4], ['已成功', 5]]
  include HrLib::Functions

  scope :successed, where(:status_id => 5)

  %w{recommend accepted interviewed rejected succeed}.each_with_index do |n, idx|
    define_method("#{n}?") do
      self.status_id==STATUS[idx][1]
    end
  end

  def status
    get_array_type_text STATUS, self.status_id
  end

  def valid_record
    c = Contact.find_by_id(self.contact_id)
    errors.add(:contact_id, "联系人ID不存在") unless c
    return false unless errors.empty?
  end

  def change_record
    change_demand_status(3)
    send_msg("有顾问推荐了候选人！", 1)
  end

  def check_status
    user = Hr.user

    if self.interview_date_changed?&&self.interview_date_was.blank?&&!self.interview_date.blank?
      self.status_id = 3
      change_demand_status(3)
    end
    if self.feedback_date_changed?&&self.feedback_date_was.blank?&&!self.feedback_date.blank?
      change_demand_status(4)
    end

    send_msg("#{user.username}将你的推荐状态调整为：#{self.status}", 2) if self.status_id_changed?&&user.is_sales?
  end

  def change_demand_status(sid)
    demand = self.contact_demand
    demand.update_attribute('status_id', sid) if demand.status_id<sid
  end

  def send_msg(title, lead_type_id)
    url = "/sales/recommend_view/#{self.id}"
    body = %{<a href="#{url}">点击查看详细</a>}
    to_id = self.send(lead_type_id==2 ? 'contact' : 'contact_demand').firm.lead_by_id(lead_type_id).employee_id
    EmpMsg.send_msg(Hr.user.id, to_id, title, body, url) unless to_id==0
  end

  def successed?
    self.status_id == 5
  end

  def ret_id
    self.status_id
  end

  def ret_id=(sid)
    return unless [4, 5].include?(sid.to_i)
    self.status_id = sid
  end

end
