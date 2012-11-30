#encoding:utf-8
class FirmTypesController < ApplicationController

  def list
    @title = "职业类型一览"
    @firm_types = FirmType.paginate :order => "id", :per_page => 30, :page => params[:page]
  end

  def update
    type, id = params[:id].split('_')
    if FirmType.exists?(id)
      FirmType.update(id, :name => params[:name])
    end
    render :text => ""
  end

  def get_positions
    @positions = ContactPosition.where("firm_type_id = ?", params[:id])
    render :template => "firm_types/positions", :layout => false
  end

  def init_menu
    @sys_nav_menus = []
    @sys_nav_menus << ['/firm_types/list', '职业类型一览']
  end

end
