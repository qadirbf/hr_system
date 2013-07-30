#encoding:utf-8
class RolesEmployee < ActiveRecord::Base
  belongs_to :employee
  belongs_to :role
  # attr_accessible :title, :body

  def role_name
    Role::ROLES_TITLE[self.role.name.to_sym] rescue "未知"
  end
end
