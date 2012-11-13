#encoding:utf-8
class EmpMsg < ActiveRecord::Base
  belongs_to :from_user,:class_name=>"Employee",:foreign_key=>'from_id'
  belongs_to :to_user,:class_name=>"Employee",:foreign_key=>'to_id'

  def self.send_msg(from_id,to_ids,title,content,url=nil)
    to_ids = [to_ids] unless to_ids.is_a?(Array)
    to_ids = to_ids.compact.uniq
    emps = Employee.all(:select=>"id,username",:conditions=>["id in (?)",to_ids],:order=>"username")
    to_names = emps.map(&:username).join(';')
    emps.each do |e|
      self.create(:from_id=>from_id,:to_id=>e.id,:title=>title,:content=>content,:to_names=>to_names,:viewed=>0,:url=>url)
    end
  end

  def self.user_unview_count(user)
    self.count(:id,:conditions=>["viewed=0 and to_id=?",user.id])
  end

end
