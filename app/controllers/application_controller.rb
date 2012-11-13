#encoding:utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorize,:except=>:logout

  helper_method :current_user, :logged_in?

  protected
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = current_user_session
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
          reset_session unless RAILS_ENV=="development"
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
        redirect_to :controller=>"main"
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

  def init_menu

  end

end
