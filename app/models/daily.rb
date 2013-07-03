#encoding:utf-8
class Daily < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :contact
  belongs_to :firm, :foreign_key => "obj_id"
  belongs_to :created_user, :class_name => "Employee", :foreign_key => "created_by"
  belongs_to :updated_user, :class_name => "Employee", :foreign_key => "updated_by"

  def show_firm_name
    f = self.firm
    f.blank? ? self.firm_name : f.firm_name
  end

  def show_contact_name
    d = self.contact
    d.blank? ? self.contact_name : d.full_name
  end

  def edit_info
    a = self.updated_user
    unless a.blank?
       a.username + "于" + self.updated_at.format_date(:full) + "最后更新"
    end
  end

end
