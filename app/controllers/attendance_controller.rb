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

  def record_detail
    @employees = Employee.where("active=1 or leave_date>sysdate()-60").order("username")

    params[:employee_id] ||= current_user.id
    @this_employee = Employee.where("id = ?", params[:employee_id]).first

    @def_employees = Employee.where("active=1 or leave_date>sysdate()-60").order("username")

    params[:start_time] = check_date(params[:start_time],'beginning')
    params[:end_time] = check_date(params[:end_time],'end')
    @attends = Attendance.where("employee_id=? and (this_date>=str_to_date('#{params[:start_time]} 00:00:00','%Y-%m-%d %H:%i:%s') and this_date<=str_to_date('#{params[:end_time]} 23:59:59','%Y-%m-%d %H:%i:%s'))", params[:employee_id]).order("this_date desc")
    #@leaves=AttendLeave.find(:all,:conditions=>["employee_id=? and (start_date>=str_to_date('#{params[:start_time]} 00:00:00','%Y-%m-%d %H:%i:%s') and end_date<=str_to_date('#{params[:end_time]} 23:59:59','%Y-%m-%d %H:%i:%s'))",params[:employee_id]],:order=>"id desc")
  end

  protected
  def init_menu
    @sub_title="考勤系统"
    preload_permission
    @sys_nav_menus = [["/attendance/show_record", "考勤记录"],["/attendance/record_detail", "打卡记录及考勤信息"]]
                         #["/attendance/show_leave", "年假/病假"],["/attendance/serious_late", "严重迟到记录"],
                         #["/attendance/oral_application_list","口头申请"],["/attendance/apply_leave_list","正式申请"],
                         #["/attendance/forget_record_list", "忘记/未打卡申请列表"]]
    #@sys_nav_menus << ["/attendance/set_leave", "已批准的申请"] if @can_edit or @can_view
    #@sys_nav_menus << ["/attendance/show_attend", "员工考勤列表"] if @can_edit or @can_view
    #@sys_nav_menus << ["/attendance/set_holiday", "设置放假"] if @can_edit or @can_view
    #if @can_edit
    #  @sys_nav_menus << ["/attendance/summary", "统计考勤信息"]
    #  @sys_nav_menus << ["/attendance/input_record", "生成考勤信息"]
    #  @sys_nav_menus << ["/attendance/attend_operate", "考勤操作"]
    #end

  end

  def preload_permission
    @can_edit = current_user.is_admin?
    @can_view = current_user.is_admin?

    @can_edit_others_archive = current_user.is_admin?
    @can_view_others_archive = current_user.is_admin?
    @can_edit_archive = current_user.is_admin?
    @can_view_archive = current_user.is_admin?
    @can_view_group = current_user.is_admin?
  end


end
