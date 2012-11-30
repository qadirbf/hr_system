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

  # 添加职业类型
  def add
    @title = "添加职业类型"
    @firm_type = FirmType.new
    if request.post?
      @firm_type.update_attributes(params[:firm_type])
      if @firm_type.valid?
        @firm_type.save
        redirect_to :action => :list
      else
        render :action => :add
      end
    end
  end

  # 添加职位类型
  def add_position
    @title = "添加职位类型"
    @firm_types = FirmType.all.map { |f| [f.name, f.id] }
    @contact_position = ContactPosition.new
    if request.post?
      @contact_position.attributes = params[:contact_position]
      if (@contact_position.valid? and @contact_position.name_valid?)
        @contact_position.save
        redirect_to :action => :list
      else
        render :action => :add_position
      end
    end
  end

  def delete
    case params[:type]
      when "firm_type"
        if ContactPosition.exists?(:firm_type_id => params[:id])
          flash[:notice] = "该职业类型下有职位类型，需要先移除该分类下的职位类型"
        else
          FirmType.delete(params[:id])
        end
      when "contact_position"
        ContactPosition.delete(params[:id])
    end
    redirect_to :action => :list
  end

  def init_menu
    @sys_nav_menus = []
    @sys_nav_menus << ['/firm_types/list', '职业类型一览']
  end

end
