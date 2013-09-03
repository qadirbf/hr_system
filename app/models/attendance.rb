#encoding:utf-8
class Attendance < ActiveRecord::Base

  include HrLib::Functions

  LEAVE_DAYS = [["", 0], ["2小时", 0.25], ["半天", 0.5], ["6小时", 0.75], ["一天", 1]]
  ABSENCE_REASON = [["无", 0], ["旷工", 1], ["普通事假", 2], ["特殊事假", 18], ["年假", 3], ["病假", 4], ["出差", 5], ["产检", 6], ["产假", 7], ["婚假", 8], ["丧假", 9], ["调休", 10], ["因公外出", 11],
                    ["因不可抗力上班未打卡", 12], ["因不可抗力下班未打卡", 16], ['加班', 13], ["上班忘记打卡", 14], ["下班忘记打卡", 17], ["哺乳假", 15]]
  S_TIME = '09:00:00'
  E_TIME = '18:00:00'

  def absence_day
    get_array_type_text LEAVE_DAYS, self.absence
  end

  def reason
    get_array_type_text ABSENCE_REASON, self.absence_reason
  end

  def all_absence_labels
    labels = self.attend_applies.map { |apply| "<a href='/attendance/apply_leave_show?id=#{apply.apply_leave_id}' target='_blank' style='margin-bottom:3px;display:block'>#{apply.reason_label}(#{apply.absence_label})</a>" }.join
    labels << (self.apply_leave_id ? "<a href='/attendance/apply_leave_show?id=#{self.apply_leave_id}' target='_blank'>#{self.reason}(#{self.absence_day})</a>" : "#{self.reason}(#{self.absence_day})") if self.absence_reason.to_i > 0
    return labels
  end

  def self.create_attends
    from = Date.parse("2012-12-20")
    to = Date.today
    (from...to).each do |day|
      Attendance.add_attendance(day.to_s, "09:05:00", "18:00:00", false)
    end
  end

  def self.create_yesterday_attendance
    yesterday = Date.today - 1.day
    Attendance.add_attendance(yesterday.to_s, "09:05:00", "18:00:00", false)
  end

  def self.add_attendance(this_date, real_start_time, real_end_time, flag, user_name=nil)
    setted_records = Attendance.where("employee_id = -1 and this_date = str_to_date('#{this_date} 00:00:00', '%Y-%m-%d %H:%i:%s')").all
    setted_records.uniq!
    if setted_records.size > 0
      setted_records.each do |record| #记录已设置上下班时间公司员工的考勤信息
        self. (this_date, record.real_start_time, record.real_end_time, true, user_name)
      end
    else
      self.create_employee_attendance(this_date, real_start_time, real_end_time, flag, user_name)
    end
  end

  def self.create_employee_attendance(this_date, real_start_time, real_end_time, flag, user_name=nil, emp_id=nil)
    sql = "active = 1 "
    if emp_id
      sql += (emp_id.is_a?(Array) ? ' and id in (?)' : ' and id = ?')
      employees = Employee.find(:all, :conditions => [sql, emp_id], :order => "username")
    else
      employees = Employee.find(:all, :conditions => sql, :order => "username")
    end

    if (![0, 6].include?(Time.parse(this_date).wday)) and flag #如果为周末，默认为不处理，若flag为true则照常处理
      employees.each do |employee|
        unless Attendance.exists?("employee_id = #{employee.id} and this_date = '#{this_date}'")
          record_in = AttendRecord.get_clock_in_record(employee.id, this_date)
          record_out = AttendRecord.get_clock_out_record(employee.id, this_date)
          attend = Attendance.new({:employee_id => employee.id, :this_date => this_date, :real_start_time => record_in.try(:record_time),
                                   :real_end_time => record_out.try(:record_time), :edit_by => user_name||'system', :edit_time => Time.now, :early => 0, :late => 0, :absence_reason => 0})
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

  def self.special_attend_sets(start_date, end_date, emp_id=nil)
    attends = Attendance.all(:conditions => ["employee_id=-1 and this_date between ? and ?",
                                             start_date.beginning_of_day, end_date.end_of_day], :order => "this_date")
    rets = []
    attends.each do |attend|
      if r = rets.find { |ret| ret.this_date==attend.this_date }
        rets.delete(r)
      end
      rets << attend
    end
    rets
  end

  def self.rebuild_attendances(employee_id, start_time, end_time)
    if start_time > end_time
      raise "结束时间必须大于开始时间！"
    elsif start_time.format_date(:date) == end_time.format_date(:date)
      rebuild_employee_attendance(employee_id, start_time)
    else
      rebuild_employee_attendance(employee_id, start_time)
      temp_time = start_time+1.day
      while temp_time < (end_time-1.day).end_of_day
        rebuild_employee_attendance(employee_id, temp_time)
        temp_time += 1.day
      end
      rebuild_employee_attendance(employee_id, end_time)
    end
  end

  def self.rebuild_employee_attendance(emp_id, this_date)
    this_date_str = format_date(this_date.beginning_of_day, :full)
    employee = Employee.first(:conditions=>["id = ?", emp_id])
    attend = self.first(:conditions=>["this_date = ? and employee_id = ?", this_date_str, emp_id])
    attend.destroy if attend
    setted_record = Attendance.where("employee_id = -1 and this_date = '#{this_date_str}'")
    if setted_record
      create_employee_attendance(nil, this_date.format_date(:date), setted_record.real_start_time, setted_record.real_end_time, true, Hr.user.username, emp_id)
    else
      create_employee_attendance(nil, this_date.format_date(:date), S_TIME, E_TIME, true, Hr.user.username, emp_id) unless [0,6].include?(this_date.wday)
    end
  end


end
