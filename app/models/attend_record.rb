#encoding:utf-8
class AttendRecord < ActiveRecord::Base
  belongs_to :employee

  def self.get_clock_in_record(employee_id, day)
    get_record(employee_id, day, 1)
  end

  def self.get_clock_out_record(employee_id, day)
    get_record(employee_id, day, 2)
  end

  def self.get_record(employee_id, day, flag)
    if flag==1
      record = AttendRecord.where("employee_id=? and attend_type=1 and record_time like '%#{day}%'", employee_id).order("record_time desc")
    else
      record = AttendRecord.where("employee_id=? and attend_type=2 and record_time like '%#{day}%'", employee_id).order("record_time desc")
    end
    return record
  end

end
