#encoding:utf-8
class FirmTag < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :firm
  belongs_to :tag
end
