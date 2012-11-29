#encoding:utf-8
class FirmTypesController < ApplicationController

  def list
    @title = "职位类型一览"
    @firm_types = FirmType.paginate :order => "id", :per_page => 30, :page => params[:page]
  end

  def init_menu
    @sys_nav_menus = []
    @sys_nav_menus << ['/firm_types/list', '职业类型一览']
    @sys_nav_menus << ['/firm_types/list', '职位类型一览']
  end

end
