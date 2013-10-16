#encoding:utf-8
module DailyController

  def my_daily
    @title = "我的日报"
    @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }
    _sql, hash = Daily.get_sql_by_hash(params)
    sql = [_sql]
    if params[:created_by_eq].blank?
      sql << "created_by = :created_by"
      hash.merge!({:created_by => current_user.id})
    end
    sql.delete_if { |a| a.blank? }
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
      (1..10).each do |i|
        if !daily["phone_#{i}"].blank? && !daily["firm_name_#{i}"].blank? && !daily["contact_name_#{i}"].blank? && !daily["day_#{i}"].blank?
          ary << [daily["firm_name_#{i}"], daily["obj_id_#{i}"], daily["contact_name_#{i}"], daily["contact_id_#{i}"],
                  daily["phone_#{i}"], daily["day_#{i}"], daily["notes_#{i}"], daily["position_cn_#{i}"], daily["completed_flag_#{i}"],
                  daily["demand_id_#{i}"], daily["app_interview_date_#{i}"], daily["qq_#{i}"]]
        end
      end

      ary.each do |d|
        # 如果该公司不在系统内，则保存该公司到系统内
        if d[1].blank? && d[0]
          firm = Firm.where("firm_name like '%#{d[0].strip}%'").first
          if firm.blank?
            firm = Firm.new(:firm_name => d[0], :created_by => current_user.id, :updated_by => current_user.id)
            firm.save(:validate => false)
          end
          d[0], d[1] = [firm.firm_name, firm.id]
        end
        # 联系人是否在系统内，否则添加到系统
        if d[3].blank?
          contact = Contact.new({:firm_id => d[1], :mobile => d[4], :first_name => "", :last_name => d[2], :position_cn => d[7], :qq => d[11]})
          contact.save(:validate => false)
          d[3] = contact.id
        else
          contact = Contact.where("id = #{d[3]} and firm_id = #{d[1]}").first
          unless contact.blank?
            contact.update_attributes({:firm_id => d[1], :mobile => d[4], :first_name => "", :last_name => d[2], :position_cn => d[7], :qq => d[11]})
          end
        end
        flag = (d[5] > Time.now.strftime("%Y-%m-%d") ? 0 : d[8].to_i) # 标记是否已完成的日报
        if flag > 0 #已完成的日报，同步一条call
          r = Recall.create({:appt_date => d[5], :employee_id => current_user.id, :firm_id => d[1], :contact_id => d[3],
                             :notes => d[6], :completed_by => current_user.id, :created_by => current_user.id, :contact_by_id => 1,
                             :completed_at => Time.now})
        else
          r = Recall.create({:appt_date => d[5], :employee_id => current_user.id, :firm_id => d[1], :contact_id => d[3],
                             :notes => d[6], :created_by => current_user.id, :contact_by_id => 1})
        end

        Daily.create({:firm_name => d[0], :obj_id => d[1], :contact_name => d[2], :contact_id => d[3], :phone => d[4],
                      :day => d[5], :notes => d[6], :position_cn => d[7], :completed_flag => flag, :created_by => current_user.id,
                      :updated_by => current_user.id, :recall_id => r.try(:id), :demand_id => d[9], :app_interview_date => d[10], :qq => d[11]})
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
      flag = (@daily.day.to_s > Time.now.strftime("%Y-%m-%d") ? 0 : @daily.completed_flag.to_i) # 标记是否已完成的日报
      if @daily.recall_id.blank? # 没有同步call
        call = Recall.create({:appt_date => @daily.day, :employee_id => @daily.created_by, :firm_id => @daily.obj_id, :contact_id => @daily.try(:contact_id),
                              :notes => @daily.notes, :created_by => @daily.created_by, :contact_by_id => 1})
        @daily.update_attributes({:recall_id => call.id})
      else # 如果已经同步了call的情况
        call = Recall.where("id = #{@daily.recall_id}").first
        call.update_attribute(:notes, @daily.notes)
      end
      if flag > 0 #已完成的日报，并且没有同步recall
        call.update_attributes({:completed_by => @daily.created_by, :contact_by_id => 1, :completed_at => Time.now})
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
    @results = Firm.where("firm_name like '%#{key.strip}%'").all
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

  def interview_list
    @title = "面试安排"
    @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }
    _sql, hash = Daily.get_sql_by_hash(params)
    sql = [_sql]
    sql << "app_interview_date is not null and app_interview_date != ''"
    if params[:created_by_eq].blank?
      if current_user.right_level > 3
        sql << "created_by is not null"
      else
        sql << "created_by = :created_by"
        hash.merge!({:created_by => current_user.id})
      end
    end
    sql.delete_if { |a| a.blank? }
    @dailies = Daily.paginate :conditions => [sql.join(" and "), hash], :order => "day desc, created_at desc", :per_page => 20, :page => params[:page]
    render :template => "/daily/interview_list"
  end

  def output_daily
    if request.post? && !params[:id].blank?
      demand = ContactDemand.where("id = #{params[:id]}").first
      if current_user.right_level > 2
        ary = Daily.find_by_sql("select obj_id, count(obj_id) as num from dailies where demand_id = #{params[:id].to_i} group by obj_id order by num desc;").collect(&:obj_id)
        dailies = Daily.where("demand_id = ?", demand.id).order("find_in_set(obj_id,'#{ary.join(',')}')")
      else
        ary = Daily.find_by_sql("select obj_id, count(obj_id) as num from dailies where demand_id = #{params[:id].to_i} and created_by = #{current_user.id} group by obj_id order by num desc;").collect(&:obj_id)
        dailies = Daily.where("demand_id = ? and created_by = #{current_user.id}", demand.id).order("find_in_set(obj_id,'#{ary.join(',')}')")
      end

      send_data(xls_content_for_daily(dailies, demand),
                :type => "text/excel;charset=utf-8; header=present",
                :filename => "#{demand.firm.firm_name}-#{demand.position_type_text}.xls")
    else
      render :template => "/daily/output_daily"
    end
  end

  def get_project
    d = ContactDemand.where("id = #{params[:id]}").first
    if d
      render :text => %?{"success":"true","firm_name":"#{d.firm.firm_name}","position":"#{d.position_type_text}"}?
    else
      render :text => %?{"success":"false","info":"没有查到该项目数据！"}?
    end

  end

  def xls_content_for_daily(objs, demand)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "工作报告"

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
    sheet1.row(0).default_format = blue

    sheet1.row(0).concat(["公司名", demand.firm.firm_name])
    sheet1.row(1).concat(["招聘职位", demand.position_type_text])

    sheet1.row(3).concat %w{ 公司名 联系人 电话 职位 日期 员工 面试安排 备注 }
    count_row = 4
    objs.each do |obj|
      daily = obj
      sheet1[count_row, 0]= daily.show_firm_name
      sheet1[count_row, 1]= daily.show_contact_name
      sheet1[count_row, 2]= daily.phone
      sheet1[count_row, 3]= daily.position_cn
      sheet1[count_row, 4]= daily.day
      sheet1[count_row, 5]= daily.created_user.username
      sheet1[count_row, 6]= daily.app_interview_date
      sheet1[count_row, 7]= daily.notes
      count_row += 1
    end
    book.write xls_report
    xls_report.string
  end

end
