#encoding:utf-8
module DailyController

  def my_daily
    @title = "我的日报"
    @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }
    _sql, hash = Daily.get_sql_by_hash(params)
    sql = [_sql]
    if params[:created_by_eq].blank?
      sql <<  "created_by = :created_by"
      hash.merge!({:created_by => current_user.id})
    end
    sql.delete_if{|a| a.blank? }
    @dailies = Daily.paginate :conditions => [sql.join(" and "), hash], :order => "day desc, created_at desc", :per_page => 20, :page => params[:page]
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
        if !daily["phone_#{i}"].blank? && !daily["firm_name_#{i}"].blank? && !daily["contact_name_#{i}"].blank? && !daily["day_#{i}"].blank?
          ary << [daily["firm_name_#{i}"], daily["obj_id_#{i}"], daily["contact_name_#{i}"], daily["contact_id_#{i}"],
                  daily["phone_#{i}"], daily["day_#{i}"], daily["notes_#{i}"], daily["position_cn_#{i}"], daily["completed_flag_#{i}"]]
        end
      end

      ary.each do |d|
        # 联系人是否在系统内，否则添加到系统
        if d[3].blank?
          contact = Contact.new({:firm_id => d[1], :first_name => d[2], :last_name => "", :position_cn => d[7]})
          contact.save(:validate => false)
          d[3] = contact.id
        end
        flag = (d[5] > Time.now.strftime("%Y-%m-%d") ? 0 : d[8].to_i)  # 标记是否已完成的日报
        if flag > 0  #已完成的日报，同步一条call
          r = Recall.create({:appt_date => d[5], :employee_id => current_user.id, :firm_id => d[1], :contact_id => d[3],
                         :notes => d[6], :completed_by => current_user.id, :created_by => current_user.id, :contact_by_id => 1,
                         :completed_at => Time.now})
        else
          r = Recall.create({:appt_date => d[5], :employee_id => current_user.id, :firm_id => d[1], :contact_id => d[3],
                         :notes => d[6], :created_by => current_user.id, :contact_by_id => 1})
        end

        Daily.create({:firm_name => d[0], :obj_id => d[1], :contact_name => d[2], :contact_id => d[3], :phone => d[4],
                      :day => d[5], :notes => d[6], :position_cn => d[7], :completed_flag => flag, :created_by => current_user.id,
                      :updated_by => current_user.id, :recall_id => r.try(:id)})
      end
      redirect_to :action => :my_daily
    end

  end

  def daily_update
    user = current_user
    unless params[:id].blank?
      @daily = Daily.find(params[:id])
      @daily.attributes = params[:daily].merge(:updated_by => user.id)
    else
      @daily = Daily.new(params[:daily].merge(:created_by => user.id, :updated_by => user.id))
    end
    if @daily.errors.empty?
      @daily.save
      flag = (@daily.day.to_s > Time.now.strftime("%Y-%m-%d") ? 0 : @daily.completed_flag.to_i)  # 标记是否已完成的日报
      if flag > 0  #已完成的日报，同步一条call
        Recall.create({:appt_date => @daily.day, :employee_id => @daily.created_by, :firm_id => @daily.obj_id, :contact_id => @daily.try(:contact_id),
                           :notes => @daily.notes, :completed_by => @daily.created_by, :created_by => @daily.created_by, :contact_by_id => 1,
                           :completed_at => Time.now})
      else
        Recall.create({:appt_date => @daily.day, :employee_id => @daily.created_by, :firm_id => @daily.obj_id, :contact_id => @daily.try(:contact_id),
                           :notes => @daily.notes, :created_by => @daily.created_by, :contact_by_id => 1})
      end
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
