#encoding:utf-8
class OtherOrder < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :order
end
