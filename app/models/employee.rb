#encoding:utf-8
class Employee < ActiveRecord::Base
  validates_presence_of :username,:message=>"请填写用户名！"
  validates_presence_of :password,:message=>"请填写密码！"
  validates_presence_of :department_id,:message=>"请选择部门！"
  validates_presence_of :active,:message=>"请选择是否允许登录！"
  validates_uniqueness_of :username,:message=>"用户名已经存在！"
  belongs_to :department
  has_many :attend_records

  include HrLib::Security

  scope :active_emps,where(:active=>1)
  scope :sales,where(:department_id=>1)
  scope :res,where(:department_id=>2)
  scope :dep_emps,lambda{|dep_id| where(:department_id=>dep_id)}
  attr_accessor :click_count

  %w{sales res hr}.each_with_index do |name,idx|
    define_method("is_#{name}?") do
      return true if self.is_admin?
      self.department_id==idx+1
    end
  end

  def is_admin?
    self.id==1
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

end
