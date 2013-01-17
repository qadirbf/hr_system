#encoding:utf-8
class AttendanceController < ApplicationController

  def add_record
    uid = current_user.id
    if uid
      flag = params[:flag].to_i
      attend_record = AttendRecord.where("employee_id = ? and attend_type = ? and record_time like ?", uid, flag, Time.now.strftime("%Y-%m-%d")+'%').first
      if attend_record.blank?
        attend_record = AttendRecord.new()
        attend_record.employee_id = uid
        attend_record.record_time = Time.now
        attend_record.attend_type = flag
        attend_record.ip = request.remote_ip()
      else
        attend_record.record_time = Time.now if flag == 2
      end

      attend_record.save
      redirect_to :action => "attend_notice", :rtype => (flag == 1 ? "in" : "out")

      #render :text=>"<script>alert('#{notice}!');window.location.href='/attendance/show_record'</script>"
    else
      flash[:notice] = "please login!"
      redirect_to(:controller => 'employees', :action => 'login')
    end
  end

  def attend_notice
    render :layout => false
  end

  def show_record
    @var_time = check_date(params[:record_time])

    @start_date = @var_time[0, 7] + "-01"
    @end_date = @var_time

    week = Time.parse(@var_time).wday
    w_labels = %w{天 一 二 三 四 五 六}
    @weekday = "星期#{w_labels[week]}"

    @employees = Employee.all(:select=>"username,name_cn,id",:conditions=>["active=1"],:order=>"username")
    @employees.reject!{|e| e.id == current_user.id}
    @employees.unshift(current_user)

    params[:record_time] = @var_time

    @pre_time = (Time.parse(@var_time)-1.day).strftime("%Y-%m-%d")
    @nex_time = (Time.parse(@var_time)+1.day).strftime("%Y-%m-%d")
    @ths_time = Time.now.strftime("%Y-%m-%d")
    @last_attend = Attendance.where("employee_id = ?",  current_user.id).order("this_date desc").first
    @in_records = AttendRecord.where("employee_id in (?) and attend_type = 1 and record_time like ?", @employees.map(&:id), "#{@var_time}%").
        inject({}) { |h, r| h[r.employee_id]=r; h }
    @out_records = AttendRecord.where("employee_id in (?) and attend_type = 2 and record_time like ?", @employees.map(&:id), "#{@var_time}%").
        inject({}) { |h, r| h[r.employee_id]=r; h }
    puts @in_records
    puts '---------'
    puts @out_records
    puts '========='

    @attends = Attendance.all(:conditions=>"employee_id > 0 and this_date=('#{@var_time} 00:00:00')")
    @holiday = false #假期设置
  end

  def check_date(var_date, when_blank='now')
    unless var_date.blank?
      Time.parse(var_date).strftime("%Y-%m-%d")
    else
      if when_blank.class.name == 'Fixnum'
        (Time.now+when_blank.days).strftime("%Y-%m-%d")
      else
        case when_blank
          when 'beginning';
            Time.now.at_beginning_of_month.strftime("%Y-%m-%d");
          when 'end';
            Time.now.at_end_of_month.strftime("%Y-%m-%d")
          else
            Time.now.strftime("%Y-%m-%d");
        end
      end
    end
  rescue
    check_date(nil, when_blank)
  end


end
