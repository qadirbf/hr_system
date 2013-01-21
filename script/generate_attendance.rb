#encoding: utf-8
time = Time.now.strftime("%Y-%m-%d")
employees = Employee.where("active=1 or leave_date>sysdate()-60").order("username")
attends = AttendRecord.where("record_time like ?", time + "%")
employees.each do |e|
  attendance = Attendance.new(:employee_id => e.id)
  attendance.this_date = Time.now
  attendance.holiday = 0
  in_time = attends.select { |a| a.employee_id == e.id && a.attend_type == 1 } #上班打卡时间
  out_time = attends.select { |a| a.employee_id == e.id && a.attend_type == 2 } #上班打卡时间
  attendance.real_start_time = in_time
  attendance.real_end_time = out_time
  attendance.early = 1 if in_time.strftime("%H:%M:%S") > Attendance::S_TIME
  attendance.late  = 1 if out_time.strftime("%H:%M:%S") < Attendance::S_TIME
  attendance.save
end