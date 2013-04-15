#encoding:utf-8
class EmployeesController < ApplicationController

  def edit
    unless params[:id].blank?
      @title = "修改员工"
      @employee = Employee.find(params[:id])
    else
      @title = "添加员工"
      @employee = Employee.new
    end
    @departments = Department.all.map{|d| [d.name,d.id]}
  end

  def update
    user = current_user
    unless params[:id].blank?
      @employee = Employee.find(params[:id])
      @employee.update_attributes(params[:employee].merge(:updated_by=>user.id))
    else
      @employee = Employee.create(params[:employee].merge(:updated_by=>user.id,:created_by=>user.id))
    end
    if @employee.errors.empty?
      flash[:notice] = "成功保存！"
      redirect_to :action=>"view",:id=>@employee.id
    else
      @title = params[:id].blank? ? "添加员工" : "修改员工"
      @departments = Department.all.map{|d| [d.name,d.id]}
      render :action=>"edit"
    end
  end

  def view
    @title = "员工信息"
    @employee = Employee.find(params[:id])
  end

  def destroy
    e = Employee.find(params[:id])
    if FirmLead.exists?(["employee_id = ?", e.id]) # 离职前把leads设置为空置
      FirmLead.update_all("employee_id = 0", "employee_id = #{e.id}")
    end
    e.destroy
    flash[:notice] = "成功删除！"
    redirect_to :action=>"list"
  end

  def list
    @title = "员工列表"
    @departments = Department.all.map{|d| [d.name,d.id]}

    @employees = Employee.paginate :conditions=>Employee.get_sql_by_hash(params),:order=>"username",
                                   :per_page=>30,:page=>params[:page]
  end

  def login
    @title = "请登录"
    if request.post?
      user = Employee.active_emps.authenticate(params[:username],params[:password])
      if user


        UserSession.user_login_check(request.session_options[:id], user, request.remote_ip())

        session[:user_id] = user.id
        Hr.user = user
        user.click_count = 0

        flash[:notice] = "成功登录！"
        flash[:last_url] = flash[:last_url] if flash[:last_url]
        LoginHistory.add_history user.username,nil,user.id,nil,request.remote_ip,0

        # 打卡
        record_in = AttendRecord.get_clock_in_record(user.id, Time.now.format_date(:date))
        not_need_record = (!record_in.blank? || user.is_admin?)
        record_url = url_for(:controller => "attendance", :action => "attend_notice", :rtype => "notice")

        redirect_to(not_need_record ? url_for(:controller => "main") : record_url)
        return false
      else
        raise AppError, "用户名或密码错误！"
      end
    end
    render :layout => "sign"
  rescue AppError => e
    flash[:notice] = "用户名或密码错误！"
    LoginHistory.add_history params[:username],params[:password],nil,nil,request.remote_ip, 1
    redirect_to :action=>"login"
  end

  def logout
    reset_session
    flash[:notice] = "成功退出系统！"
    redirect_to :action=>"login"
  end

  protected

  def init_menu
    unless logged_in?
      @sys_nav_menus = [['/employees/login','登录']]
    else
      @sys_nav_menus = [['/employees/list','员工列表']]
    end
  end

end
