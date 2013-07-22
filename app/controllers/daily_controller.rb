#encoding:utf-8
module DailyController

  def my_daily
    @title = "我的日报"
    @dailies = Daily.paginate :conditions => "created_by = #{current_user.id}", :per_page => 20, :page => params[:page]
    render :template => "/daily/my_daily"
  end

  def daily_edit
    unless params[:id].blank?
      @title = "修改日报"
      @daily = Daily.find(params[:id])
    else
      @title = "添加日报"
      @daily = Daily.new(:obj_name => "")
      if crm_sys?

      end
    end
    render :template => "/daily/daily_edit"
  end

  def add_daily
    unless request.post?
      @title = "添加日报"
      render :template => "/daily/add_daily"
    else
      daily = params[:daily]
      ary = []
      (1..5).each do |i|
        if !daily["name_#{i}"].blank? && !daily["firm_name_#{i}"].blank? && !daily["contact_name_#{i}"].blank? && !daily["day_#{i}"].blank?
          ary << [daily["name_#{i}"], daily["firm_name_#{i}"], daily["obj_id_#{i}"], daily["contact_name_#{i}"], daily["contact_id_#{i}"], daily["day_#{i}"], daily["notes_#{i}"]]
        end
      end

      ary.each do |d|
        Daily.create({:name => d[0], :firm_name => d[1], :obj_id => d[2], :contact_name => d[3], :contact_id => d[4],
                      :day => d[5], :notes => d[6], :created_by => current_user.id, :updated_by => current_user.id})
      end
      redirect_to :action => :my_daily
    end

  end

  def daily_update
    user = current_user
    unless params[:id].blank?
      @daily = Daily.find(params[:id])
      @daily.update_attributes(params[:daily].merge(:updated_by => user.id))
    else
      @daily = Daily.create(params[:daily].merge(:created_by => user.id, :updated_by => user.id))
    end
    if @daily.errors.empty?
      flash[:notice] = "成功保存！"
      redirect_to :action => "my_daily", :controller => params[:db_type]
    else
      @title = params[:id].blank? ? "添加日报" : "修改日报"
      render :action => "daily_edit"
    end
  end

  def daily_view
    @title = "查看日报"
    @daily = Daily.find(params[:id])
    render :template => "/daily/daily_view"
  end

  def daily_destroy
    daily = Daily.find params[:id]
    if daily.created_by == current_user.id
      daily.destroy
    else
      flash[:notice] = "只能删除自己的日报！"
    end
    redirect_to :action => "my_daily"
  end

  def auto_object
    key = params[:q] if params[:q]
    @results = Firm.where("firm_name like '%#{key}%'").all
    render :template => "/daily/auto_firm"
  end

  # 日报统计
  def count_daily
    @title = "日报统计"
    @emps = Employee.active_emps.select('id,username')
    params[:day_eq] = Time.now.format_date(:date) if params[:day_eq].blank?
    ary = Daily.get_sql_by_hash(params)
    @dailies = Daily.paginate :conditions => ary, :per_page => 20, :page => params[:page]
    render :template => "/daily/count_daily"
  end

end
