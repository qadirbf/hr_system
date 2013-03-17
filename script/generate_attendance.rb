#encoding: utf-8
require "class_ext"

LOG_FILE = Rails.root.to_s + '/log/attendance_schedule.log'
def write_logs(result)
  puts result
  f = File.new(LOG_FILE, "a+")
  f.puts result
  f.close
end

begin
  write_logs "Started at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

  ActiveRecord::Base.transaction do
    Attendance.add_attendance(Time.now.strftime("%Y-%m-%d"), "09:05:00", "18:15:00", false)
  end

  write_logs "Ended at #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

rescue  => e
  write_logs "Error at #{Time.now}, because of #{e}"
end

#log.add '---begin---'
#time = Time.now.format_date(:date)
#employees = Employee.where("active=1 or leave_date>sysdate()-60").order("username")
#attends = AttendRecord.where("record_time like ?", time + "%")
#i = 0
#c = employees.size
#employees.each do |e|
#  puts "............#{i + 1} / #{c}"
#  attendance = Attendance.new(:employee_id => e.id)
#  attendance.this_date = Time.now
#  attendance.holiday = 0
#  in_time = attends.select { |a| a.employee_id == e.id && a.attend_type == 1 }.first.record_time.format_date(:hour) rescue "23:59:59" #上班打卡时间
#  out_time = attends.select { |a| a.employee_id == e.id && a.attend_type == 2 }.first.record_time.format_date(:hour) rescue "00:00:00" #上班打卡时间
#  attendance.real_start_time = in_time
#  attendance.real_end_time = out_time
#  attendance.early = 1 if in_time > Attendance::S_TIME
#  attendance.late  = 1 if out_time < Attendance::E_TIME
#  attendance.save
#end
#puts '---end---'