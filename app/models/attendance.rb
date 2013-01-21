#encoding:utf-8
class Attendance < ActiveRecord::Base

  LEAVE_DAYS = [["", 0], ["2小时", 0.25], ["半天", 0.5], ["6小时", 0.75], ["一天", 1]]
  ABSENCE_REASON = [["无", 0], ["旷工", 1], ["普通事假",2],["特殊事假",18], ["年假", 3], ["病假", 4], ["出差", 5], ["产检", 6], ["产假", 7], ["婚假", 8], ["丧假", 9], ["调休", 10], ["因公外出", 11],
                    ["因不可抗力上班未打卡", 12], ["因不可抗力下班未打卡", 16], ['加班', 13], ["上班忘记打卡", 14], ["下班忘记打卡", 17], ["哺乳假", 15]]
  S_TIME = '09:00:00'
  E_TIME = '18:00:00'

  def all_absence_labels
    labels = self.attend_applies.map{|apply| "<a href='/attendance/apply_leave_show?id=#{apply.apply_leave_id}' target='_blank' style='margin-bottom:3px;display:block'>#{apply.reason_label}(#{apply.absence_label})</a>"}.join
    labels << (self.apply_leave_id ? "<a href='/attendance/apply_leave_show?id=#{self.apply_leave_id}' target='_blank'>#{self.reason}(#{self.absence_day})</a>" : "#{self.reason}(#{self.absence_day})") if self.absence_reason.to_i > 0
    return labels
  end

end
