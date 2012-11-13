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
        redirect_to :controller=>"main"
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
