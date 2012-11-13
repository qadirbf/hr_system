#encoding:utf-8
class MsgController < ApplicationController

  def msg_list
    @title ||= "消息列表"
    @emps = Employee.active_emps.select("id,username").order("username").map{|e| [e.username,e.id]}
    sql,p_hash = EmpMsg.get_sql_by_hash(params)
    sql = "1=1" if sql.blank?
    sql << " and to_id=#{current_user.id}"

    @msgs = EmpMsg.paginate :conditions=>[sql,p_hash],:order=>"created_at desc",:per_page=>3,:page=>params[:page]
  end

  def unviewed_list
    @title = "未读消息"
    params[:viewed_eq] = '0'
    msg_list
    render :template=>"/msg/msg_list"
  end

  def set_viewed
    EmpMsg.update_all('viewed=1',["id in (?)",params[:ids]])
    flash[:notice] = "操作成功！"
    redirect_to :action=>params[:b_action]
  end

  def msg_view
    @title = "查看消息"
    @msg = EmpMsg.find(params[:id])
    @msg.update_attributes(:viewed=>1)
    redirect_to(@msg.url) and return unless @msg.url.blank?
  end

  protected

  def init_menu
    @sys_title = "消息系统"
    @sys_nav_menus = [['/msg/unviewed_list','未读消息'],['/msg/msg_list','消息列表']]
  end

end
