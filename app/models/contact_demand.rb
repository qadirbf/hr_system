#encoding:utf-8
class ContactDemand < ActiveRecord::Base
  belongs_to :firm
  belongs_to :employee
  belongs_to :firm_type
  belongs_to :position_type,:class_name=>"ContactPosition",:foreign_key=>"position_type_id"
  belongs_to :province
  belongs_to :city
  has_many :recommend_histories
  belongs_to :updated_user,:class_name=>"Employee",:foreign_key=>"updated_by"
  validates_presence_of :firm_id,:message=>"必须关联公司"
  validates_presence_of :firm_type_id,:message=>"请选择职业类型"
  validates_presence_of :position_type_id,:message=>"请选择职位类型"
  validates_presence_of :salary_type_id,:message=>"请选择年薪范围"
  validates_presence_of :province_id,:message=>"请选择工作所在省份"
  validates_presence_of :city_id,:message=>"请选择工作所在城市"
  validates_presence_of :contact_num,:message=>"请填写招聘人数"


  STATUS = [['草稿',1],['已发布',2],['已推荐面试',3],['已反馈',4],['已到款',5],['已结束',6]]
  include HrLib::Functions

  %w{draft published interviewed feedback paid finished}.each_with_index do |n,idx|
    define_method("#{n}?") do
      self.status_id==STATUS[idx][1]
    end
  end

  def self.position_description_file_folder
    "public/position_description"
  end

  def status
    get_array_type_text STATUS,self.status_id
  end

  def salary_type
    get_array_type_text Contact::SALARY_TYPES,self.salary_type_id
  end

end
