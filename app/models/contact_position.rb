#encoding:utf-8
class ContactPosition < ActiveRecord::Base
  belongs_to :firm_type
  validates_presence_of :name, :message => "名称不能为空"
  validates_presence_of :firm_type_id, :message => "职业类型不能为空"
  #validates_uniqueness_of :name, :message => "该名称已经存在", :if => Proc.new{} :on => :create

  def name_valid?
    unless self.firm_type_id.blank?
      if self.id.blank?
        c = ContactPosition.where("firm_type_id = ? and name = ?", self.firm_type_id, self.name)
      else
        c = ContactPosition.where("firm_type_id = ? and name = ? and id != ?", self.firm_type_id, self.name, self.id)
      end
      self.errors.add(:name, "该分类下已经存在这个名称了") unless c.blank?
    end
    self.errors[:name].blank?
  end

  def self.get_positions(firm_type_id)
    self.all(:conditions => ["firm_type_id=?", firm_type_id], :order => "id")
  end

  def to_s
    self.name
  end

end
