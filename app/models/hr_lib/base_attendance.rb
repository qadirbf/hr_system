#encoding:utf-8
module HrLib
  module BaseAttendance

    ABSENCES = [["", 0],["2小时", 0.25],["半天", 0.5],["6小时", 0.75],["一天", 1]]
    REASONS = [["无",0],["旷工",1],["普通事假",2],["特殊事假",18],["年假",3],["病假",4],["出差",5],["产检",6],["产假",7],["婚假",8],["丧假",9],["调休",10],["因公外出",11],
               ["因不可抗力上班未打卡",12],["因不可抗力下班未打卡",16],['加班',13],["上班忘记打卡",14],["下班忘记打卡",17],["哺乳假",15]]

    module ClassMethods

      def get_leave_time(start_time,end_time)
        if start_time.hour == 12
          start_time = Time.local(start_time.year,start_time.month,start_time.day,13)
        elsif end_time.hour == 13
          end_time = Time.local(start_time.year,start_time.month,start_time.day,12)
        end
        raise "开始时间大于结束时间，不符合逻辑！" if start_time > end_time
        dtime = end_time - start_time
        dtime -= 1.hour if start_time.hour <= 12 and end_time.hour >= 13 #减去午休时间
        dhour = (dtime/3600).ceil
        dhour = (dhour%2==0 ? dhour : dhour + 1)
        return dhour/2*0.25
      end

      def beginning_of_work_day(time)
        Time.parse("#{time.format_date(:date)} 09:00")
      end

      def end_of_work_day(time)
        Time.parse("#{time.format_date(:date)} 18:00")
      end

      def get_workdays_ago(time,days)
        get_workdays_since(time,days,-1)
      end

      def get_workdays_since(time,days,sign=1)
        dcount = 0
        while dcount < days
          time += sign.day
          dcount += 1 unless AttendHoliday.not_work_day?(time)
        end
        return time
      end

    end

    def self.included(receiver)
      receiver.extend(ClassMethods)
    end

  end
end