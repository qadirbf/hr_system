#encoding:utf-8
class FirmType < ActiveRecord::Base
  has_many :contact_positions
  validates_presence_of :name, :message => "名称不能为空"
  validates_uniqueness_of :name, :message => "该名称已经存在", :on => :create

  def to_s
    self.name
  end

end
