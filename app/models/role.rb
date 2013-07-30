#encoding:utf-8
class Role < ActiveRecord::Base
  has_many :roles_employees

  ROLES_TITLE = {:admin=>"管理员",:manager=>"经理",:leader=>"主管",:sales=>"销售",:adviser=>"顾问"}
  # attr_accessible :title, :body
end
