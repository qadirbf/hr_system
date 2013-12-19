#encoding:utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :refuse_spider
  before_filter :authorize, :except => [:logout, :auto_object, :auto_contact]
  #before_filter :need_check_attendance, :except => [:login, :logout]

  helper_method :current_user, :logged_in?

  protected
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session
  end

  def refuse_spider
    agent = request.user_agent
    s = ['YodaoBot','sogou spider','Slurp','Msnbot','Yahoo Slurp','Googlebot','Baiduspider', 'bingbot']
    return if (!agent.blank? and s.any?{|bot| agent.downcase.include?(bot.downcase)})
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    if session[:user_id]
      @current_user_session = Employee.find(session[:user_id])
    else
      nil
    end
  end

  def logged_in?
    current_user
  end

  def authorize
    Hr.user = current_user
    @msg_count = EmpMsg.user_unview_count(current_user) if logged_in?
    unless params[:controller]=="employees"&&params[:action]=="login"
      if session[:last_visit_time]
        if session[:last_visit_time] + $CLIENT_EXPIRE_MINUTES.minutes < Time.now
          reset_session unless ENV['RAILS_ENV'] == "development"
        end
      end

      unless logged_in?
        raise AppError, "请先登录系统！"
      else
        init_menu
        current_user.click_count += 1 rescue current_user.click_count = 0
      end
    else
      if logged_in?
        UserSession.user_view_check(request)
        flash[:notice] = "已经登录！"
        redirect_to :controller => "main"
        return
      else
        init_menu
      end
    end
  rescue AppError => e
    flash[:notice] = "#{e}"
    flash[:last_url] = request.env["REQUEST_URI"]
    redirect_to '/login.php'
    return false
  end

  def need_check_attendance
    return if %w{attendance main msg}.include?(params[:controller])
    #return if RAILS_ENV=='development'
    if session[:attend_info]
      return if current_user.is_admin?
      attend = Attendance.find(session[:attend_info][:attendance_id])
      notice = "<img src='/images/notice_pic.gif'> <span style='font-size:14px;'>"
      notice << "#{attend.this_date}日的考勤可能与实际不符，请核实后进行一下操作："
      notice << "<p><a href='/attendance/confirm_absence/#{attend.id}' style='margin:5px;color:blue;'>确认无误</a>(将发消息通知管理员)</p>" unless attend.absence_reason==1
      notice << "<p><a href='/attendance/apply_leave_edit' style='margin:5px;color:blue;'>考勤有误，提交申请</a></p>"
      if session[:attend_info][:notice_count]<=3
        notice << "<p><a href='/attendance/skip_for_urgent?skip_type=attend' style='margin:5px;color:blue;'>下次提醒，继续使用系统</a></p>"
      end
      notice << "<div style='color:red'>当前为第#{session[:attend_info][:notice_count]}次提醒，如果超过3次，系统会强制您做出处理！</div></span>"
      flash[:notice] = notice.html_safe
      redirect_to :controller => '/attendance', :action => 'show_record',
                  :record_time => attend.this_date
    elsif session[:apply_info]
      notice = "<img src='/images/notice_pic.gif'> <span style='font-size:14px;'>"
      notice << "您有未审批的申请，必须审批所有申请后才可以进行其他操作！".red
      notice << "<p><a href='/attendance/apply_leave_list?need_approved=on' target='_blank' style='margin:5px;color:blue;display:block;'>所有需要我审批的申请</a></p>"
      if session[:apply_info][:notice_count]<=3
        notice << "<p><a href='/attendance/skip_for_urgent?skip_type=apply' style='margin:5px;color:blue;display:block;'>下次提醒，继续使用系统</a></p>"
      end
      notice << "<div style='color:red'>当前为第#{session[:apply_info][:notice_count]}次提醒，如果超过3次，系统会强制您做出处理！</div></span>"
      flash[:notice] = notice.html_safe
      redirect_to :controller => '/attendance', :action => "apply_leave_show", :id => session[:apply_info][:apply_leave_id]
    end
  end

  def check_attendance
    #return unless ENV['RAILS_ENV'] == 'production'
    p_hash = {:employee_id => session[:user_id], :start_date => Time.local(2013, 9, 1).beginning_of_day,
              :end_date => Time.now.end_of_day}
    #=========检查是否有需要调整的考勤==========
    attend = Attendance.first(:conditions => ["not exists (select id from apply_leaves where status in (1,2,3) and
      start_date<=attendances.this_date and end_date>=attendances.this_date and employee_id=:employee_id)
      and not exists (select id from attend_checks where attendance_id=attendances.id and active = 0)
      and (absence_reason=1 or late=2 or early=2 )
      and employee_id=:employee_id and this_date between :start_date and :end_date", p_hash])
    if attend
      check = AttendCheck.find_by_attendance_id(attend.id)
      if check
        if check.active!=0
          check.notice_count += 1
          check.save
          session[:attend_info] = {:notice_count => check.notice_count, :attendance_id => check.attendance_id}
        end
      else
        check = AttendCheck.create(:attendance_id => attend.id, :employee_id => attend.employee_id, :notice_count => 1, :active => 1)
        session[:attend_info] = {:notice_count => check.notice_count, :attendance_id => check.attendance_id}
      end
    end

    #===========检查是否有需要审批的申请================
    apply = ApplyLeave.first(:conditions => ["(start_date>=:start_date or end_date>:start_date )
      and ((status=1 and apply_to_hr=:employee_id) or (status=3 and apply_to=:employee_id))", p_hash])
    if apply
      check = AttendCheck.find_by_apply_leave_id(apply.id)
      if check
        if check.active!=0
          check.notice_count += 1
          check.save
          session[:apply_info] = {:notice_count => check.notice_count, :apply_leave_id => check.apply_leave_id}
        end
      else
        check = AttendCheck.create(:apply_leave_id => apply.id, :employee_id => apply.employee_id, :notice_count => 1, :active => 1)
        session[:apply_info] = {:notice_count => check.notice_count, :apply_leave_id => check.apply_leave_id}
      end
    end
  end

  def init_menu

  end

end
