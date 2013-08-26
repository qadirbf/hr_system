#encoding:utf-8
class Employee < ActiveRecord::Base
  validates_presence_of :username, :message => "请填写用户名！"
  validates_presence_of :password, :message => "请填写密码！"
  validates_presence_of :department_id, :message => "请选择部门！"
  validates_presence_of :active, :message => "请选择是否允许登录！"
  validates_uniqueness_of :username, :message => "用户名已经存在！"
  belongs_to :department
  has_many :firms, :foreign_key => "signing_sales"
  has_many :attend_records
  has_many :orders
  has_many :share_orders
  has_many :dailies
  has_one :roles_employee

  include HrLib::Security

  scope :active_emps, where(:active => 1)
  scope :sales, where("department_id = 1 or id = 1")
  scope :res, where("department_id = 2 or id = 1")
  scope :dep_emps, lambda { |dep_id| where(:department_id => dep_id) }
  attr_accessor :click_count

  %w{sales res hr}.each_with_index do |name, idx|
    define_method("is_#{name}?") do
      return true if self.is_admin?
      self.department_id==idx+1
    end
  end

  def is_admin?
    self.id==1
  end

  def is_manager?
    self.right_level == 4
  end

  def is_leader?
    self.right_level == 3
  end

  def to_s
    self.username
  end

  def leads_type_id
    self.is_sales? ? 1 : 2
  end

  def active_label
    self.active==1 ? '是' : '否'
  end

  def role_id
    self.roles_employee.role_id rescue 0
  end

  def right_level
    role_name = self.roles_employee.role.name rescue ""
    case role_name
      when "admin"
        5
      when "manager"
        4
      when "leader"
        3
      else
        2
    end
  end

  #def in_trial_time?
  #  return false if self.is_trusted?
  #  archive = self.employee_archive
  #  return true unless archive
  #  return true if archive.formal_date.blank?
  #  return archive.formal_date > Time.now
  #end

end
