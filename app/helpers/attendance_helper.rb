module AttendanceHelper

  def late_count(employee_id, start_time, end_time)
    count = Array.new(2, 0)
    attends = Attendance.where("late>0 and employee_id=? and  (this_date>=str_to_date('#{start_time} 00:00:01','%Y-%m-%d %H:%i:%s') and this_date<=str_to_date('#{end_time} 23:59:59','%Y-%m-%d %H:%i:%s'))", employee_id)
    attends.each do |attend|
      count[0] += 1
      if attend.late.to_i == 2
        count[1] += 1
      end
    end
    forget_record_count = AttendLeave.count(:id, :conditions => ["absence_reason=14 and employee_id = ?
      and start_date between str_to_date('#{start_time} 00:00:01','%Y-%m-%d %H:%i:%s') and str_to_date('#{end_time} 23:59:59','%Y-%m-%d %H:%i:%s')", employee_id])
    forget_record_count -= 2
    count[0] += forget_record_count if forget_record_count > 0
    return count
  end

  def early_count(employee_id, start_time, end_time)
    count = Array.new(2, 0)
    attends = Attendance.where("early>0 and employee_id=? and  (this_date>=str_to_date('#{start_time} 00:00:01','%Y-%m-%d %H:%i:%s') and this_date<=str_to_date('#{end_time} 23:59:59','%Y-%m-%d %H:%i:%s'))", employee_id)
    attends.each do |attend|
      count[0] += 1
      if attend.early.to_i == 2
        count[1] += 1
      end
    end
    return count
  end

  def absence_count(employee_id, start_time, end_time)
    count = 0
    attends = Attendance.where
        ("attendances.employee_id=#{employee_id} and (this_date>=str_to_date('#{start_time} 00:00:00','%Y-%m-%d %H:%i:%s') and this_date<=str_to_date('#{end_time} 23:59:59','%Y-%m-%d %H:%i:%s'))
        and (attendances.absence_reason in (1,2,3,4,6,7,8,9) or attend_applies.absence_reason in (2,3,4,6,7,8,9))")
        .joins("left join attend_applies on attend_applies.attendance_id = attendances.id")
        .select("distinct attendances.absence,attendances.id,attendances.absence_reason")
    #attends = Attendance.find(:all, :select => "distinct attendances.absence,attendances.id,attendances.absence_reason", :joins => "left join attend_applies on attend_applies.attendance_id = attendances.id",
    #                        :conditions => "attendances.employee_id=#{employee_id} and (this_date>=to_date('#{start_time} 00:00:00') and this_date<=to_date('#{end_time} 23:59:59'))
    #    and (attendances.absence_reason in (1,2,3,4,6,7,8,9) or attend_applies.absence_reason in (2,3,4,6,7,8,9))")
    attends.each do |attend|
      count += attend.attend_applies.select { |apply| [2, 3, 4, 6, 7, 8, 9].include?(apply.absence_reason) }.map { |a| a.absence }.inject(0) { |sum, c| sum+c }
      count += attend.absence if [1, 2, 3, 4, 6, 7, 8, 9].include?(attend.absence_reason)
    end
    return count
  end
end
