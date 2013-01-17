#encoding:utf-8
class Tag < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :firm_tags
end
