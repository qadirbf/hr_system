#encoding:utf-8
class AttendCheck < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :attendance
end
