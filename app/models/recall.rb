#encoding:utf-8
class Recall < ActiveRecord::Base
  belongs_to :firm
  belongs_to :contact
  belongs_to :employee
  validates_presence_of :appt_date,:message=>"请选择安排时间"
  validates_presence_of :contact_by_id,:message=>"请选择联系方式"
  validates_presence_of :employee_id,:message=>"请选择跟进员工"

  IMPORTANT_TYPES = [['普通', 0], ['重要', 1], ['非常重要', 2]]
  CONTACT_BY = [["Email", 4], ["传真", 2], ["会面", 5], ["电话", 1], ["邮件", 3], ["短信", 6]]
  STAGES = [['介绍业务',1],['联系招聘需求',2],['推荐职位',3],['催款',4]]

  include HrLib::Functions

  scope :dep_recalls,lambda{|dep_id| joins("join employees e on e.id=recalls.employee_id").where(["e.department_id=?",dep_id])}

  def important_type
    get_array_type_text IMPORTANT_TYPES,self.important
  end

  def contact_by_label
    get_array_type_text CONTACT_BY,self.contact_by_id
  end

  def stage
    get_array_type_text STAGES,self.stage_id
  end

  def complete
    self.completed_at.blank? ? 0 : 1
  end

  def complete=(n)
    if n.to_i==1
      self.completed_at = Time.now
      self.completed_by = Hr.user.id
    else
      self.completed_at = nil
      self.completed_by = nil
    end
  end

end
