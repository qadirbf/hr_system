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

    @employees = Employee.all(:select => "username,name_cn,id", :conditions => ["active=1"], :order => "username")
    @employees.reject! { |e| e.id == current_user.id }
    @employees.unshift(current_user)

    params[:record_time] = @var_time

    @pre_time = (Time.parse(@var_time)-1.day).strftime("%Y-%m-%d")
    @nex_time = (Time.parse(@var_time)+1.day).strftime("%Y-%m-%d")
    @ths_time = Time.now.strftime("%Y-%m-%d")
    @last_attend = Attendance.where("employee_id = ?", current_user.id).order("this_date desc").first
    @in_records = AttendRecord.where("employee_id in (?) and attend_type = 1 and record_time like ?", @employees.map(&:id), "#{@var_time}%").
        inject({}) { |h, r| h[r.employee_id]=r; h }
    @out_records = AttendRecord.where("employee_id in (?) and attend_type = 2 and record_time like ?", @employees.map(&:id), "#{@var_time}%").
        inject({}) { |h, r| h[r.employee_id]=r; h }

    @attends = Attendance.all(:conditions => "employee_id > 0 and this_date=('#{@var_time} 00:00:00')")
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

  def apply_leave_list
    @sub_title = "正式申请列表"
    @can_edit_others = current_user.is_admin?
    #@can_apply_for_others = OralApplication.can_add_oral_application?(Reach.current_user_id)
    #@can_submit_apply_for_others = session[:current_user].has_permission?('can_submit_attendance_apply_for_others')
    @employees = Employee.active_emps
    #第一次进入列表时，默认显示“我的尚未被审批的申请”
    if !request.post? and %w{not_approved need_approved}.all? { |f| params[f.to_sym].blank? }
      params[:employee_id] = current_user.id
      params[:not_approved] = 'on'
    end
    #member_ids = OralApplication.members(Reach.current_user_id).compact.map{|e| [[e.username,"(#{e.name_cn})"].join,e.id]}.map{|m| m[1]}
    @def_employees = []
    @def_employees = @employees #@employees.select{|e| member_ids.include?(e.id)} if member_ids.size > 0
    params[:order]||='start_date'
    p_hash = params.dup; p_hash[:start_date] = "#{params[:start_date]} 00:00:00"; p_hash[:end_date] = "#{params[:end_date]} 23:59:59"
    if params[:employee_id].blank?
      p_hash[:employee_id] = (@def_employees.size >0 ? @def_employees.map { |e| e.id } : [current_user.id])
    else
      p_hash[:employee_id] = [params[:employee_id]]
    end

    sql = "1=1"
    sql += " and apply_leaves.employee_id in (:employee_id)"
    sql += " and apply_leaves.absence_reason = :absence_reason" unless params[:absence_reason].blank?
    sql += " and apply_leaves.apply_to = :apply_to" unless params[:apply_to].blank?
    sql += " and apply_leaves.status = :status" unless params[:status].blank?
    sql += " and apply_leaves.start_date >= str_to_date(:start_date,'%Y-%m-%d %H:%i:%s')" unless params[:start_date].blank?
    sql += " and apply_leaves.end_date <= str_to_date(:end_date,'%Y-%m-%d %H:%i:%s')" unless params[:end_date].blank?
    #我的尚未被审批的申请
    sql += " and apply_leaves.status in (1,2,3)" unless params[:not_approved].blank?
    #所有需要我审批的申请
    sql += " and ((status=1 and apply_to_hr=#{current_user.id}) or (status=3 and apply_to=#{current_user.id}))" unless params[:need_approved].blank?
    select = "employees.username,employees.name_cn,apply_leaves.*"
    order = "apply_leaves.#{params[:order]} desc"

    @applies = ApplyLeave.paginate :select => select, :conditions => [sql, p_hash], :joins => "left join employees on employees.id = apply_leaves.employee_id",
                                   :order => order, :per_page => 30, :page => params[:page]
  end

  def record_detail
    @employees = Employee.where("active=1 or leave_date>sysdate()-60").order("username")

    params[:employee_id] ||= current_user.id
    @this_employee = Employee.where("id = ?", params[:employee_id]).first

    @def_employees = Employee.where("active=1 or leave_date>sysdate()-60").order("username")

    params[:start_time] = check_date(params[:start_time], 'beginning')
    params[:end_time] = check_date(params[:end_time], 'end')
    @attends = Attendance.where("employee_id=? and (this_date>=str_to_date('#{params[:start_time]} 00:00:00','%Y-%m-%d %H:%i:%s') and this_date<=str_to_date('#{params[:end_time]} 23:59:59','%Y-%m-%d %H:%i:%s'))", params[:employee_id]).order("this_date desc")
    #@leaves=AttendLeave.find(:all,:conditions=>["employee_id=? and (start_date>=str_to_date('#{params[:start_time]} 00:00:00','%Y-%m-%d %H:%i:%s') and end_date<=str_to_date('#{params[:end_time]} 23:59:59','%Y-%m-%d %H:%i:%s'))",params[:employee_id]],:order=>"id desc")
  end

  def apply_leave_edit
    unless params[:id].blank?
      @title = "修改申请"
      @apply = ApplyLeave.find(params[:id])
    else
      @title = "添加申请"
      p_hash = {:employee_id => current_user.id}
      @apply = ApplyLeave.new(p_hash)
    end
    @notes = YAML.load(@apply.leave_notes||' ')
    preload_apply
  end

  def apply_leave_update
    params[:out]||={}
    unless params[:out][:out_type].blank?
      params[:apply][:leave_notes] = params[:out].to_yaml
    else
      params[:apply][:leave_notes] = params[:leave_notes]
    end
    unless params[:id].blank?
      @apply = ApplyLeave.find(params[:id])
      @apply.update_attributes(params[:apply].merge({:updated_by => current_user.id}))
    else
      params[:apply][:employee_id]||= current_user.id
      @apply = ApplyLeave.new(params[:apply].merge({:status => 0, :created_by => current_user.id, :updated_by => current_user.id}))
    end
    @apply.upload_file(params[:attachment]) unless params[:attachment].blank?
    if @apply.save
      if @apply.absence_reason==4
        action = "confirm_sick_leave"
        notice = "请确认病假信息"
      else
        action = "apply_leave_approve"
        notice = "请选择审批主管"
      end
      flash[:notice] = "成功保存,#{notice}！"
      redirect_to :action => action, :id => @apply.id
    else
      @sub_title = (params[:id].blank? ? "添加申请" : "修改申请")
      preload_apply
      render :template => "/attendance/apply_leave_edit"
    end
  rescue => e
    render :text => "<script>alert('#{e.to_s.tr("\"\'\r\n", " ")}');history.back();</script>"
  end

  def apply_leave_approve
    @title = "请选择审批主管"
    @apply = ApplyLeave.find(params[:id])
    @managers = @apply.approval_managers

    @info = (@apply.end_date && @apply.end_date.hour >= 18) ? "如果预计不能赶回公司，请务必在外出前打下班卡，否则算忘记打卡！" : nil
    if request.post?
      raise "请选择审批主管！" if params[:apply_to].blank?
      raise "该主管不能对您的申请进行审批，请选择其他主管！" unless @managers.map { |m| m.id }.include?(params[:apply_to].to_i)
      p_hash = (@apply.is_draft? ? {:status => 1, :apply_to => params[:apply_to]} : {:status => 3, :apply_to => params[:apply_to]})
      @apply.update_attributes(p_hash.merge!({:back_reason => nil})) #对退回修改后再提交的申请，需要请退回原因清空
      raise @apply.errors.full_messages.join("<br>") if @apply.errors.size > 0
      @apply.send_message_for_apply

      session[:attend_info] = nil if session[:attend_info]

      flash[:notice] = "操作成功！"
      redirect_to :action => "apply_leave_show", :id => @apply.id
    end
  rescue => e
    @notice = e.is_a?(RuntimeError) ? e.to_s : e.backtrace.join("<br>")
    @managers ||= []                                                  .
    render :template => "/attendance/apply_leave_approve"
  end

  def apply_leave_show
    @sub_title = "员工申请"
    @apply = ApplyLeave.find(params[:id])
    @notes = @apply.notes_label
    @send_msg_to_ids = @apply.get_send_msg_to
    @send_msg_to = Employee.all(:select => "id,username,name_cn,active", :conditions => ["id in (?)", @send_msg_to_ids], :order => "username").
        reject { |em| em.active==0 }.map { |e| "#{e.username}(#{e.name_cn})" }.join(',')

    cdn1 = ([@apply.apply_to, @apply.apply_to_hr, @apply.employee_id]+@send_msg_to_ids).compact.uniq.map { |i| i.to_i }.include?(current_user.id)
    cdn2 = current_user.is_admin?
    @can_view_attachment = cdn1||cdn2

    @can_hr_check, @can_manager_check, @can_change_managers = false, false, []
    admin = Employee.where("username = 'admin'").first
    emp = @apply.employee

    @can_change_managers << admin
    @can_change_managers = @can_change_managers
    m_ids = @can_change_managers.map { |e| e.id }
    @can_manager_check = true if m_ids.include?(current_user.id)

    #@checks = AttendCheck.find_by_sql("select a.* from attend_checks ac left join attendances a on a.id=ac.attendance_id where
    #    a.this_date between to_date1('#{@apply.start_date.format_date(:date)} 00:00:00') and to_date1('#{@apply.end_date.format_date(:date)} 23:00:00')
    #    and ac.active=0 and a.employee_id=#{@apply.employee_id}")
    #@apply.manager_notes = "该员工曾将 #{@checks.map{|c| c.this_date.format_date(:date)}.join('、')}的考勤设置为“确认无误”" if @checks.size>0&&@can_manager_check

  end

  def cancel_apply
    @apply = ApplyLeave.find(params[:id])
    if params[:by]=='self'
      if request.post?
        @apply.update_attributes({:cancel_reason => params[:cancel_reason]})
        @apply.cancel_apply
        flash[:notice] = '申请已取消！'
        redirect_to :action => "apply_leave_show", :id => @apply.id
      else
        @sub_content_title = "取消申请"
      end
    elsif params[:by]=='manager'
      @apply.cancel_apply
      flash[:notice] = '申请已取消！'
      redirect_to :action => "apply_leave_show", :id => @apply.id
    end
  end

  def apply_cancel_to_manager
    @apply = ApplyLeave.find(params[:id])
    if request.post?
      @apply.update_attributes({:cancel_reason => params[:cancel_reason], :apply_cancel => 1})
      @apply.send_message_for_apply_cancel_to_manager
      flash[:notice] = '成功提交申请！'
      redirect_to :action => "apply_leave_show", :id => @apply.id
    else
      @sub_content_title = "取消申请"
      render :template => "/attendance/cancel_apply"
    end
  end

  def apply_back
    @apply = ApplyLeave.find(params[:id])
    if request.post?
      @apply.update_attributes({:back_reason => params[:back_reason]})
      @apply.send_message_for_apply_back
      flash[:notice] = '操作成功！'
      redirect_to :action => "apply_leave_show", :id => @apply.id
    else
      @sub_content_title = "申请退回"
    end
  end

  def input_record
    params[:this_date] = params[:this_date]||Time.now.strftime("%Y-%m-%d")
  end

  def add_attendance
    begin
      Timeout.timeout(1800) do
        this_date = params[:this_date]
        this_date = Time.now.strftime("%Y-%m-%d") if this_date.blank?
        #check=Attendance.find(:first,:conditions=>"branch_office_id=#{branch_office_id} and this_date like '%#{this_date}%'")
        real_start_time = params[:real_start_time]
        real_start_time = Attendance::S_TIME if (real_start_time == "" or real_start_time.blank?)
        real_end_time = params[:real_end_time]
        real_end_time = Attendance::E_TIME if real_end_time == "" or real_end_time.blank?

        if params[:record_exist].to_i == 1 #重新生成时，删除已存在的信息
          Attendance.destroy_all(["employee_id > 0 and this_date = to_date1('#{this_date} 00:00:00')"])
        end

        flag = params[:flag]
        Attendance.add_attendance(this_date, real_start_time, real_end_time, flag, current_user.username)
        flash[:notice] = "操作成功！"
        redirect_to(:action => 'show_record', :record_time => this_date)
      end
    rescue => e
      if e.to_s.include?("execution expired")
        render(:text => "执行超时")
      else
        raise e
      end
    end
  end

  protected
  def init_menu
    @sub_title="考勤系统"
    preload_permission
    @sys_nav_menus = [["/attendance/show_record", "考勤记录"], ["/attendance/record_detail", "打卡记录及考勤信息"], ["/attendance/apply_leave_list", "正式申请"]]
    #["/attendance/show_leave", "年假/病假"],["/attendance/serious_late", "严重迟到记录"],
    #["/attendance/oral_application_list","口头申请"],["/attendance/apply_leave_list","正式申请"],
    #["/attendance/forget_record_list", "忘记/未打卡申请列表"]]
    #@sys_nav_menus << ["/attendance/set_leave", "已批准的申请"] if @can_edit or @can_view
    #@sys_nav_menus << ["/attendance/show_attend", "员工考勤列表"] if @can_edit or @can_view
    #@sys_nav_menus << ["/attendance/set_holiday", "设置放假"] if @can_edit or @can_view
    if @can_edit
      #@sys_nav_menus << ["/attendance/summary", "统计考勤信息"]
      @sys_nav_menus << ["/attendance/input_record", "生成考勤信息"]
      #@sys_nav_menus << ["/attendance/attend_operate", "考勤操作"]
    end

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

  def preload_apply
    @can_submit_apply_for_others = current_user.is_admin?
    @members = Employee.active_emps.map { |e| [[e.username, "(#{e.name_cn})"].join, e.id] }
    @absence_reasons = YAML.load(YAML.dump(ApplyLeave::ABSENCE_REASON))
    @absence_reasons = @absence_reasons.each { |r| r[0]+="（集体网络中断、停电、公司门被锁无法进入等）" if [12, 16].include?(r[1]) }
    @absence_reasons = @absence_reasons.reject { |arr| [12, 13, 16].include?(arr[1]) } unless @can_submit_apply_for_others
  end


end
