#encoding:utf-8
class MainController < ApplicationController

  def index
    @msgs = EmpMsg.where(["to_id=? and viewed=0",current_user.id]).order("created_at desc")
  end

  protected

  def init_menu
    @sys_nav_menus = [['/main/index','首页']]
  end
end
