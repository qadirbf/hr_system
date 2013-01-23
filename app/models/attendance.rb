#encoding:utf-8
class Attendance < ActiveRecord::Base

  LEAVE_DAYS = [["", 0], ["2小时", 0.25], ["半天", 0.5], ["6小时", 0.75], ["一天", 1]]
  ABSENCE_REASON = [["无", 0], ["旷工", 1], ["普通事假", 2], ["特殊事假", 18], ["年假", 3], ["病假", 4], ["出差", 5], ["产检", 6], ["产假", 7], ["婚假", 8], ["丧假", 9], ["调休", 10], ["因公外出", 11],
                    ["因不可抗力上班未打卡", 12], ["因不可抗力下班未打卡", 16], ['加班', 13], ["上班忘记打卡", 14], ["下班忘记打卡", 17], ["哺乳假", 15]]
  S_TIME = '09:00:00'
  E_TIME = '18:00:00'

  def all_absence_labels
    labels = self.attend_applies.map { |apply| "<a href='/attendance/apply_leave_show?id=#{apply.apply_leave_id}' target='_blank' style='margin-bottom:3px;display:block'>#{apply.reason_label}(#{apply.absence_label})</a>" }.join
    labels << (self.apply_leave_id ? "<a href='/attendance/apply_leave_show?id=#{self.apply_leave_id}' target='_blank'>#{self.reason}(#{self.absence_day})</a>" : "#{self.reason}(#{self.absence_day})") if self.absence_reason.to_i > 0
    return labels
  end

  def self.add_attendance(this_date, real_start_time, real_end_time, flag, user_name=nil)
    setted_records = Attendance.where("employee_id = -1 and this_date = str_to_date('#{this_date} 00:00:00', '%Y-%m-%d %H:%i:%s')")
    setted_records.uniq!
    if setted_records.size > 0
      setted_records.each do |record| #记录已设置上下班时间公司员工的考勤信息
        self.create_employee_attendance(this_date, record.real_start_time, record.real_end_time, true, user_name)
      end
    else
      self.create_employee_attendance(this_date, real_start_time, real_end_time, flag, user_name)
    end
  end

  def self.create_employee_attendance(this_date, real_start_time, real_end_time, flag, user_name=nil, emp_id=nil)
    sql = "active = 1 "
    if emp_id
      sql += (emp_id.is_a?(Array) ? ' and id in (?)' : ' and id = ?')
      employees = Employee.all(:conditions => [sql, emp_id], :order => "username")
    else
      employees = Employee.all(:conditions => sql, :order => "username")
    end

    unless (Time.parse(this_date).wday==6 or Time.parse(this_date).wday==0) and flag==false #如果为周末，默认为不处理，若flag为true则照常处理
      employees.each do |employee|
        record_in = AttendRecord.get_clock_in_record(employee.id, this_date)
        record_out = AttendRecord.get_clock_out_record(employee.id, this_date)
        attend = Attendance.new({:employee_id => employee.id, :this_date => this_date, :real_start_time => real_start_time,
                                 :real_end_time => real_end_time, :edit_by => user_name||'system', :edit_time => Time.now, :early => 0, :late => 0, :absence_reason => 0})
        attend.memo = "已离职" unless employee.leave_date.blank?
        this_start_time = Time.parse("#{this_date} #{real_start_time}")
        this_end_time = Time.parse("#{this_date} #{real_end_time}")

        unless record_in.blank?
          attend.start_time = record_in.record_time.to_s[11, 8]
          attend.start_ip = record_in.ip
          if (record_in.record_time > this_start_time)
            if record_in.record_time > this_start_time + 10.minutes
              attend.late = 2
            else
              attend.late = 1       #普通迟到
            end
          end
        end

        unless record_out.blank?
          attend.end_time = record_out.record_time.to_s[11, 8]
          attend.end_ip = record_out.ip
          if (record_out.record_time < this_end_time)
            if record_out.record_time < this_end_time - 15.minutes
              attend.early = 2
            else
              attend.early = 1
            end
          end
        end

        if record_in.blank? || record_out.blank?
          attend.absence = 1
          attend.absence_reason = 1
        end

        attend.save
      end
    end
  end

end
