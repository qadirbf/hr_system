#encoding:utf-8
class Daily < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :contacts
end
