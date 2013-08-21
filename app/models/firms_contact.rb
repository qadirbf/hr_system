#encoding:utf-8
class FirmsContact < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :firm
end
