#encoding:utf-8
class ShareOrder < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :order
  belongs_to :employee
end
