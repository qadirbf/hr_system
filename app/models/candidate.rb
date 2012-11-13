#encoding: utf-8
class Candidate < ActiveRecord::Base
  belongs_to :contact
  belongs_to :grab_user,:class_name=>'Employee',:foreign_key=>"grab_by"
  belongs_to :submit_res,:class_name=>'Employee',:foreign_key=>"employee_id"

  def grab_info
    ["推荐顾问：#{self.submit_res} at #{self.created_at.label}"].join.html_safe
  end

end
