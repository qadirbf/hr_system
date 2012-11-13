#encoding:utf-8
class Contact < ActiveRecord::Base
  belongs_to :firm
  belongs_to :province
  belongs_to :city
  belongs_to :firm_type
  belongs_to :position,:class_name=>'ContactPosition',:foreign_key=>"position_type_id"
  belongs_to :expect_firm_type,:class_name=>'FirmType',:foreign_key=>"expect_firm_type_id"
  belongs_to :expect_position,:class_name=>'ContactPosition',:foreign_key=>"expect_position_type_id"
  belongs_to :created_user,:class_name=>'Employee',:foreign_key=>"created_by"
  belongs_to :updated_user,:class_name=>'Employee',:foreign_key=>"updated_by"
  belongs_to :grab_res,:class_name=>'Employee',:foreign_key=>"employee_id"
  has_one :candidate
  has_many :recalls
  has_many :recommend_histories
  validates_presence_of :last_name,:message=>"请填写联系人的姓"
  validates_presence_of :first_name,:message=>"请填写联系人的名字"
  validates_presence_of :salutation,:message=>"请填写联系人的称呼"
  SALARY_TYPES = [['10万以内',1],['10-20万',2],['20-40万',3],['40-60万',4],['60-100万',5],['100万以上',6],['其他',7]]

  scope :grabbed, ->(res_id) { where(:employee_id => res_id).order("last_name, first_name") }

  include HrLib::Functions
  before_save :check_sex

  def self.resume_file_folder
    "public/resumes"
  end

  def full_name(s=false,p=false)
    r = [[self.last_name,self.first_name].join]
    r << self.salutation if s
    r << (self.position&&self.position.name) if p
    r.compact.join(' ')
  end

  def age_label
    return '' if self.birthday.blank?
    ((Time.now - self.birthday)/1.year).ceil
  end

  def work_year_label
    return '' if self.start_work_date.blank?
    ((Time.now - self.start_work_date)/1.year).ceil
  end

  def salary_type
    get_array_type_text SALARY_TYPES,self.salary_type_id
  end

  def expect_salary_type
    get_array_type_text SALARY_TYPES,self.expect_salary
  end

  def phone1
    self.contact_no_same_as_firm==1 ? self.firm.phone : self.phone
  end

  def fax1
    self.contact_no_same_as_firm==1 ? self.firm.fax : self.fax
  end

  def address1
    self.address_same_as_firm==1 ? self.firm.address1 : self.address1
  end

  def address21
    self.address_same_as_firm==1 ? self.firm.address21 : self.address21
  end

  def check_sex
    if self.salutation_changed?&&!self.salutation.blank?
      self.sex = (self.salutation=='先生' ? 1 : 2)
    end
  end

  def is_candidate?
    self.candidate
  end

  def is_employed?
    RecommendHistory.includes(:contact_demand).where("contact_id = ? and contact_demands.status_id = 5", self.id).successed.first
  end

  def employed_start_date
    if r_his = self.is_employed?
      r_his.feedback_date
    end
  end
end
