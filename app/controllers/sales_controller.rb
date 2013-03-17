#encoding:utf-8
class SalesController < ApplicationController

  helper_method :crm_sys?, :res_sys?

  def firm_edit
    unless params[:id].blank?
      @title = "修改公司"
      @firm = Firm.find(params[:id])
    else
      unless params[:add_now]=='1'
        flash[:notice] = "添加公司之前，请先搜索下是否有重复公司！"
        redirect_to(:action => "search", :controller => params[:db_type], :add_now => 1, :format => 'php') and return
      end
      @title = "添加公司"
      @firm = Firm.new
    end
    preload_firm_edit
  end

  def firm_update
    user = current_user
    unless params[:id].blank?
      @firm = Firm.find(params[:id])
      @firm.update_attributes(params[:firm].merge(:updated_by => user.id))
    else
      @firm = Firm.create(params[:firm].merge(:created_by => user.id, :updated_by => user.id))
    end
    if @firm.errors.empty?
      flash[:notice] = "成功保存！"
      redirect_to :action => "firm_show", :controller => params[:db_type], :id => @firm.id, :format => 'php'
    else
      @title = params[:id].blank? ? "添加公司" : "修改公司"
      preload_firm_edit
      render :action => "firm_edit"
    end
  end

  def firm_view
    user = current_user
    @firm = Firm.find(params[:id])
    @title = @firm.firm_name
    @can_edit = (@firm.is_followed_by?(user) or user.is_admin?)
    @can_grab = @firm.can_grab_by?(user)
    @is_special_firm = (@firm.id == 4)
    @can_submit_order = (user.is_admin? or res_sys?)
    preload_recall
    render :template => "/sales/firm_view"
  end

  alias firm_show firm_view

  def firm_destroy
    firm = Firm.find(params[:id])
    firm.destroy
    flash[:notice] = "成功删除！"
    redirect_to :action => "search", :controller => params[:db_type], :format => 'php'
  end

  def grab_firm_batch
    unless params[:ids].blank?
      user = current_user
      notice = []
      params[:ids].split(",").each do |id|
        firm = Firm.find(id)
        if firm.can_grab_by?(user)
          firm.grab_by(user.id)
          notice << "成功获取！"
        else
          notice << "该公司已被获取！"
        end
      end
      render :text => notice.join("<br/>")
    else
      render :text => ""
    end
  end

  def ungrab_firm_batch
    unless params[:ids].blank?
      user = current_user
      notice = []
      params[:ids].split(",").each do |id|
        firm = Firm.find(id)
        if firm.is_followed_by?(user)
          firm.lead_by_id(user.leads_type_id).grab_by(0)
          notice << "成功释放！"
        else
          notice << "该公司已被释放！"
        end
      end
      render :text => notice.join("<br/>")
    else
      render :text => ""
    end
  end

  def grab_firm
    user = current_user
    firm = Firm.find(params[:id])
    if firm.can_grab_by?(user)
      firm.grab_by(user.id)
      flash[:notice] = "成功获取！"
    else
      flash[:notice] = "该公司已被获取！"
    end
    redirect_to :action => "firm_show", :controller => params[:db_type], :id => firm.id, :format => 'php'
  rescue RightError => e
    render :text => "<script>alert('#{e.to_s}');history.back()</script>".html_safe
  end

  def ungrab_firm
    user = current_user
    firm = Firm.find(params[:id])
    if firm.is_followed_by?(user)
      firm.lead_by_id(user.leads_type_id).grab_by(0)
      flash[:notice] = "成功释放！"
    else
      flash[:notice] = "没有权限！"
    end
    redirect_to :action => "firm_show", :controller => params[:db_type], :id => firm.id, :format => 'php'
  end

  def edit_firm_cat
    @firm = Firm.find(params[:firm_id])
    @firm_cat_ids = @firm.firm_categories.map { |c| c.id }
    if request.post?
      Firm.transaction do
        @firm.firm_cat_links.clear
        params[:ids].each do |id|
          @firm.firm_cat_links << FirmCatLink.new(:firm_category_id => id)
        end
        @firm.save
      end
      flash[:notice] = "成功保存！"
      redirect_to :action => "firm_show", :controller => params[:db_type], :id => @firm.id, :format => 'php'
    end
  end

  def edit_firm_tag
    @title = "修改公司标签"
    @firm = Firm.find(params[:firm_id])
    if request.post?
      Tag.transaction do
        tag = Tag.where(["name = ?", params[:name]]).first
        if tag
          unless FirmTag.exists?(["firm_id = #{@firm.id} and tag_id = #{tag.id}"])
            FirmTag.create({:firm_id => @firm.id, :tag_id => tag.id})
          end
        else
          tag = Tag.create({:name => params[:name], :created_by => current_user.id})
          FirmTag.create({:firm_id => @firm.id, :tag_id => tag.id})
        end
      end
      flash[:notice] = "成功保存！"
      redirect_to :action => "firm_show", :controller => params[:db_type], :id => @firm.id, :format => 'php'
    end
  end

  def contact_edit
    unless params[:id].blank?
      @title = "修改联系人"
      @contact = Contact.find(params[:id])
    else
      @title = "添加联系人"
      @contact = Contact.new(:firm_id => params[:firm_id])
    end
    preload_contact_edit
  end

  def contact_update
    user = current_user
    unless params[:id].blank?
      @contact = Contact.find(params[:id])
      @contact.employee_id ||= user.id if user.is_res?
      @contact.update_attributes(params[:contact].merge(:updated_by => user.id))
    else
      @contact = Contact.create(params[:contact].merge(:created_by => user.id, :updated_by => user.id))
    end
    if @contact.errors.empty?
      flash[:notice] = "成功保存！"
      unless params[:resume].blank?
        begin
          #old_resume = @contact.resume_file
          fm = FileManager.new({:root_folder_path => FileManager.expand_path(Contact.resume_file_folder), :file_max_size => 500.kilobytes, :file_exts => ['rar', 'zip', 'doc', 'docx', 'pdf']})
          #@contact.update_attributes(:resume_file => fm.upload_file(params[:resume]))
          @contact.contact_resumes << ContactResume.new({:contact_id => @contact.id, :upload_by => user.id, :load_path => fm.upload_file(params[:resume])})
            #fm.kill_file(old_resume)
        rescue RuntimeError => e
          flash[:notice] = e.to_s
        end
      end
      redirect_to :action => "contact_show", :controller => params[:db_type], :id => @contact.id, :format => "php"
    else
      @title = params[:id].blank? ? "添加联系人" : "修改联系人"
      preload_contact_edit
      render :action => "contact_edit", :format => 'php'
    end
  end

  def contact_view
    @contact = Contact.find(params[:id])
    @title = "联系人 - #{@contact.full_name(true)}"
    @firm = @contact.firm
    @can_edit = (@firm.is_followed_by?(current_user) or current_user.is_admin?)
    preload_recall
    render :template => "/sales/contact_view"
  end

  alias contact_show contact_view

  def contact_destroy
    c = Contact.find(params[:id])
    c.destroy
    flash[:notice] = '成功删除！'
    redirect_to :action => "firm_show", :controller => params[:db_type], :id => c.firm_id, :format => 'php'
  end

  def set_contact_candidate
    @contact = Contact.find(params[:id])
    if params[:cancel]
      @contact.candidate.destroy
      flash[:notice] = "成功取消候选人！"
    else
      user = current_user
      @contact.candidate = Candidate.new(:employee_id => current_user.id)
      @contact.employee_id ||= user.id if user.is_res?
      @contact.save!
      flash[:notice] = "成功设置候选人！"
    end
    redirect_to :action => "contact_view", :controller => params[:db_type], :id => @contact.id, :format => 'php'
  end

  def download_position_description
    if current_user.is_res? or current_user.is_admin?
      demand = ContactDemand.find(params[:id])
      filename = [Rails.root, ContactDemand.position_description_file_folder, demand.position_description].join('/')
      if demand.position_description && File.exists?(filename)
        send_file filename
      else
        render :text => "<script>alert('职位描述文件不存在，未上传或已被删除！');history.back()</script>".html_safe
      end
    end
  end

  def download_resume

    if current_user.is_res?
      session[:down_resume_count]||=0
      session[:down_resume_count] += 1
      if session[:down_resume_count]>10
        render :text => "<script>alert('你下载的简历数量超出了10个，将不能再下载简历！');history.back()</script>".html_safe
        return false
      end
    end

    c = ContactResume.find(params[:id])
    filename = [Rails.root, Contact.resume_file_folder, c.load_path].join('/')
    if c.load_path&&File.exists?(filename)
      send_file filename
    else
      render :text => "<script>alert('简历文件不存在，未上传或已被删除！');history.back()</script>".html_safe
    end
  end

  def contact_list
    @title = "候选人列表"
    @emps = Employee.active_emps.res.select('id,username').order("username").map { |e| [e.username, e.id] }
    load_firm_types params[:firm_type_id_eq]
    @exp_positions = params[:expect_firm_type_id_eq].blank? ? [['请先选择职业类别', '']] :
        ContactPosition.get_positions(params[:expect_firm_type_id_eq]).map { |p| [p.name, p.id] }
    @salary_types = Contact::SALARY_TYPES.map { |t| [t[0], t[1].to_s] }

    #params[:res_id]||=current_user.id

    sql, p_hash = Contact.get_sql_by_hash(params)
    sql = "1=1" if sql.blank?
    joins = %{inner join candidates on candidates.contact_id = contacts.id
      inner join firms on firms.id=contacts.firm_id left join firm_leads on firm_leads.firm_id=firms.id
      and firm_leads.leads_type_id=2 left join employees on employees.id=firm_leads.employee_id}
    unless params[:full_name].blank?
      sql << " and concat(last_name,first_name) like :full_name"
      p_hash.merge!(:full_name => "%#{params[:full_name]}%")
    end
    unless params[:firm_name].blank?
      sql << " and firms.firm_name like :firm_name"
      p_hash.merge!(:firm_name => "%#{params[:firm_name]}%")
    end
    unless params[:res_id].blank?
      sql << "  and firm_leads.employee_id=:res_id"
      p_hash.merge!(:res_id => params[:res_id])
    end
    unless params[:age].blank?
      sql << " and (datediff(now(),contacts.birthday)/365)>=:age"
      p_hash.merge!(:age => params[:age])
    end
    unless params[:age1].blank?
      sql << " and (datediff(now(),contacts.birthday)/365)<=:age1"
      p_hash.merge!(:age1 => params[:age1])
    end

    unless params[:tag_name].blank?
      joins += " left join firm_tags on firm_tags.firm_id = firms.id left join tags on tags.id = firm_tags.tag_id"
      sql << " and tags.name = :tag_name"
      p_hash.merge!(:tag_name => params[:tag_name])
    end
    @contacts = Contact.paginate :select => "contacts.*,firms.firm_name,employees.username", :joins => joins,
                                 :conditions => [sql, p_hash], :order => "candidates.created_at desc", :per_page => 30, :page => params[:page]
  end

  def recall_edit
    @title = "修改跟进任务"
    @recall = Recall.find(params[:id])
    @firm = @recall.firm
    preload_recall
    render :template => "/sales/recall/recall_edit"
  end

  def recall_update
    user = current_user
    unless params[:id].blank?
      @recall = Recall.find(params[:id])
      @recall.update_attributes(params[:recall].merge(:updated_by => user.id))
    else
      @recall = Recall.create(params[:recall].merge(:created_by => user.id, :updated_by => user.id))
    end
    if @recall.errors.empty?
      if params[:id].blank?
        render :text => "<script>alert('成功保存');window.opener.location.reload();window.close()</script>".html_safe
      else
        render :text => "<script>alert('成功保存');window.close();window.opener.close();</script>".html_safe
      end
    else
      txt = @recall.errors.messages.values.unshift("<b>遇到错误：</b>").join("<br>")
      render :text => "#{txt}".html_safe
    end
  end

  def recall_destroy
    r = Recall.find(params[:id])
    r.destroy
    flash[:notice] = '成功删除！'
    redirect_to :action => "firm_show", :controller => params[:db_type], :id => r.firm_id, :format => 'php'
  end

  def recall_finish
    recall = Recall.where("id = ?", params[:id]).first
    if recall.update_attributes({:completed_at => Time.now, :completed_by => current_user.id})
      render :json => {:result => "success", :msg => "更新成功"}
    else
      render :json => {:result => "false", :msg => "更新失败"}
    end
  end

  def my_recall
    @title = (params[:from] == "no_compt" ? "所有未完成的call" : "我的跟进任务")
    user = current_user
    if res_sys?
      @emps = Employee.active_emps.res.select('id,username').order("username").map { |e| [e.username, e.id] }
    else
      @emps = Employee.active_emps.sales.select('id,username').order("username").map { |e| [e.username, e.id] }
    end

    unless params[:complete].blank?
      params[:complete]=='1' ? params[:completed_at_not_null]=true : params[:completed_at_null] = true
    end

    if params[:appt_date_gte].blank? && params[:appt_date_lte].blank? && params[:from] != "no_compt"
      params[:appt_date_gte] = params[:appt_date_lte] = Time.now.format_date(:date)
    end
    unless user.is_admin?
      params[:employee_id_eq] = user.id
    end

    @recalls = Recall.dep_recalls(user.department_id).paginate :conditions => Recall.get_sql_by_hash(params),
                                                               :order => "appt_date desc", :per_page => 30, :page => params[:page]
  end

  def my_firms
    @title = (res_sys? ? "我的资源" : "我的公司")
    params[:user_id]||=current_user.id

    if current_user.is_admin?
      user_id = params[:user_id].to_i
      where_sql = (user_id == 0 ? ["firm_leads.employee_id > 0"] : ["firm_leads.employee_id = :user_id", {user_id: user_id}])

      @firms = Firm.includes(:firm_leads).where(where_sql).order("firm_leads.grab_date").paginate(:page => params[:page], :per_page => 30)

      if res_sys?
        @employees = Employee.active_emps.res.select('id,username').order("username").map { |e| [e.username, e.id] }
        render :template => "/sales/my_contacts"
      else
        @employees = Employee.active_emps.sales.select('id,username').order("username").map { |e| [e.username, e.id] }
      end
    else
      if res_sys?
        where_sql = ["firm_leads.employee_id = :user_id", {user_id: params[:user_id]}]
        @firms = Firm.includes(:firm_leads).where(where_sql).order("firm_leads.grab_date").paginate(
            :page => params[:page], :per_page => 30)
        render :template => "/sales/my_contacts"
      else
        @firms = Firm.includes(:firm_leads).where(["firm_leads.employee_id = ?", params[:user_id]]).order("firm_leads.grab_date").paginate(
            :page => params[:page], :per_page => 30)
      end
    end
  end

  def search
    @title = (res_sys? ? "资源搜索" : "公司搜索")
    @firm_types = FirmType.all(:order => "id").map { |t| [t.name, t.id] }
    @provinces = Province.get_provinces.map { |p| [p.name_cn, p.id] }
    @sales = Employee.active_emps.sales.select('id,username').order("username").map { |e| [e.username, e.id] }
    @res = Employee.active_emps.res.select('id,username').order("username").map { |e| [e.username, e.id] }
  end

  def search_result
    @title = "搜索结果"
    f_hash, c_hash, d_hash = params[:firm]||{}, params[:contact]||{}, params[:demand]||{}

    if f_hash.all? { |v, k| k.blank? } and c_hash.all? { |v, k| k.blank? } and d_hash.all? { |v, k| k.blank? }
      render :text => "请输入搜索条件！"
      return false
    end

    if f_hash.all? { |v, k| k.blank? } and c_hash.all? { |v, k| k.blank? } and d_hash.all? { |v, k| k.blank? }
      render :text => "请输入搜索条件！"
      return false
    end

    unless c_hash.blank?
      unless c_hash[:work_age].blank?
        c_hash.merge!(:start_work_date_lte => [(Time.now.year - c_hash[:work_age].to_i), "01", "01"].join("-"))
      end
      unless c_hash[:work_age1].blank?
        c_hash.merge!(:start_work_date_gte => [(Time.now.year - c_hash[:work_age1].to_i), "01", "01"].join("-"))
      end
    end

    f_arr, c_arr, d_arr = Firm.get_sql_by_hash(f_hash), Contact.get_sql_by_hash(c_hash), ContactDemand.get_sql_by_hash(d_hash)
    f_sqls, c_sqls, d_sqls = [f_arr[0]], [c_arr[0]], [d_arr[0]]
    f_joins, c_joins, d_joins = "", "", ""

    p_hash = f_arr[1].merge(c_arr[1]).merge(d_arr[1])
    unless f_hash[:phone_like].blank?
      c_sqls << "(contacts.phone like :phone or contacts.mobile like :phone)"
      p_hash.merge!(:phone => "%#{f_hash[:phone_like]}%")
    end
    unless f_hash[:fax_like].blank?
      c_sqls << "contacts.fax like :fax"
      p_hash.merge!(:fax => "%#{f_hash[:fax_like]}%")
    end
    unless f_hash[:address].blank?
      f_sqls << "(firms.address like :address or firms.address2 like :address)"
      c_sqls << "(contacts.address like :address or contacts.address2 like :address)"
      p_hash.merge!(:address => "%#{f_hash[:address]}%")
    end

    unless f_hash[:category_ids].blank?
      f_joins += " right join firm_cat_links on firm_cat_links.firm_id = firms.id"
      f_sqls << "(firm_cat_links.firm_category_id = :category_ids)"
      p_hash.merge!(:category_ids => f_hash[:category_ids])
    end

    unless c_hash[:full_name].blank?
      c_sqls << "concat(last_name,first_name) like :full_name"
      p_hash.merge!(:full_name => "%#{c_hash[:full_name]}%")
    end
    unless c_hash[:age].blank?
      c_sqls << "(datediff(now(),contacts.birthday)/365)>=:age"
      p_hash.merge!(:age => c_hash[:age])
    end
    unless c_hash[:age1].blank?
      c_sqls << "(datediff(now(),contacts.birthday)/365)<=:age1"
      p_hash.merge!(:age1 => c_hash[:age1])
    end
    unless c_hash[:res_id].blank?
      c_joins += " join firm_leads on firm_leads.firm_id=contacts.firm_id and firm_leads.leads_type_id=2"
      c_sqls << "firm_leads.employee_id=:res_id"
      p_hash.merge!(:res_id => c_hash[:res_id])
    end
    unless d_hash[:sales_id].blank?
      d_joins += " join firm_leads on firm_leads.firm_id=contact_demands.firm_id and firm_leads.leads_type_id=1"
      d_sqls << "firm_leads.employee_id=:sales_id"
      p_hash.merge!(:sales_id => d_hash[:sales_id])
    end

    [f_sqls, c_sqls, d_sqls].each { |a| a.reject! { |f| f.blank? } }
    tab_arr = []
    tab_arr << "select firms.id as firm_id from firms #{f_joins} where #{f_sqls.join(' and ')}" if f_sqls.size>0
    tab_arr << "select contacts.firm_id from contacts #{c_joins} where #{c_sqls.join(' and ')}" if c_sqls.size>0
    tab_arr << "select contact_demands.firm_id from contact_demands #{d_joins} where #{d_sqls.join(' and ')}" if d_sqls.size>0

    con_sql = tab_arr.size>0 ? " id in (#{tab_arr.join(' union ')})" : "1=1"

    @firms = Firm.paginate_by_sql(["select * from (select * from firms where #{con_sql} order by rating desc, id desc limit 5000) sa", p_hash],
                                  :page => params[:page], :order => "rating desc, id desc", :per_page => 30)
  end

  def auto_position
    key = params[:q] if params[:q]
    sql = []
    sql << (key.blank? ? "name is not null" : "name like '%#{key}%'")
    if params[:t].to_i != 0
      sql << "firm_type_id = #{params[:t].to_i}"
    end
    @results = ContactPosition.where(sql.join(" AND "))
    respond_to do |format|
      format.js
    end
  end

  def auto_tag
    key = params[:q] if params[:q]
    @results = Tag.where("name like '%#{key}%'")
    #respond_to do |format|
    #  format.js
    #end
    render :template => "sales/auto_position"
  end

  def delete_tag
    tag = Tag.where("id = ?", params[:id].to_i).first
    if tag
      FirmTag.transaction do
        FirmTag.delete_all(["tag_id = ?", tag.id])
        tag.destroy
        flash[:notice] = "删除成功"
      end
      redirect_to :action => "edit_firm_tag.php", :firm_id => params[:firm_id]
    end
  end

  def demand_edit
    unless params[:id].blank?
      @title = "修改招聘需求"
      @demand = ContactDemand.find(params[:id])
    else
      @title = "添加招聘需求"
      @demand = ContactDemand.new(:firm_id => params[:firm_id])
    end
    preload_demand_edit
  end

  def demand_update
    user = current_user
    unless params[:id].blank?
      @demand = ContactDemand.find(params[:id])
      @demand.update_attributes(params[:contact_demand].merge(:updated_by => user.id))
    else
      @demand = ContactDemand.create(params[:contact_demand].merge(:status_id => 1,
                                                                   :created_by => user.id, :updated_by => user.id))
    end
    if @demand.errors.empty?
      unless params[:position_description].blank?
        begin
          old_resume = @demand.position_description
          fm = FileManager.new({:root_folder_path => FileManager.expand_path(ContactDemand.position_description_file_folder), :file_max_size => 500.kilobytes, :file_exts => ['rar', 'zip', 'doc', 'docx', 'pdf']})
          @demand.update_attributes(:position_description => fm.upload_file(params[:position_description]))
          fm.kill_file(old_resume)
        rescue RuntimeError => e
          flash[:notice] = e.to_s
        end
      end
      flash[:notice] = "成功保存！"
      redirect_to :action => "demand_view", :controller => params[:db_type], :id => @demand.id, :format => "php"
    else
      @title = params[:id].blank? ? "添加招聘需求" : "修改招聘需求"
      preload_demand_edit
      render :action => "demand_edit"
    end
  end

  def demand_view
    @title = "招聘需求"
    user = current_user
    @demand = ContactDemand.find(params[:id])
    @firm = @demand.firm
    @can_edit = @firm.sales_followed_by?(user) or user.is_admin?
    @can_recommend = [2, 3, 4].include?(@demand.status_id)&&(user.is_res? or user.is_admin?)
    render :template => "/sales/demand_view"
  end

  alias demand_show demand_view

  def demand_destroy
    d = ContactDemand.find(params[:id])
    d.destroy
    flash[:notice] = '成功删除！'
    redirect_to :action => "firm_show", :controller => params[:db_type], :id => d.firm_id, :format => 'php'
  end

  def change_demand_status
    demand = ContactDemand.find(params[:id])
    demand.update_attribute('status_id', params[:status_id])
    flash[:notice] = "操作成功!"
    redirect_to :action => "demand_view", :controller => params[:db_type], :id => demand.id, :format => 'php'
  end

  def demand_list
    @title = "招聘需求列表"
    load_firm_types params[:firm_type_id_eq]
    @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }
    @salary_types = Contact::SALARY_TYPES.map { |t| [t[0], t[1].to_s] }
    @status = ContactDemand::STATUS

    sql, joins = ["1=1"], "join firms on firms.id=contact_demands.firm_id"
    _sql, p_hash = ContactDemand.get_sql_by_hash(params)
    sql << _sql unless _sql.blank?
    unless params[:firm_name].blank?
      sql << "firms.firm_name like :firm_name"
      p_hash.merge!(:firm_name => "%#{params[:firm_name]}%")
    end
    sql = sql.join(' and ')

    @demands = ContactDemand.paginate :select => "contact_demands.*,firms.firm_name", :conditions => [sql, p_hash],
                                      :joins => joins, :order => "contact_demands.created_at desc", :per_page => 30, :page => params[:page]

  end

  # delete demand
  def demand_delete
    if ContactDemand.exists?(params[:id])
      ContactDemand.delete(params[:id])
      flash[:notice] = "删除成功"
      redirect_to :action => "demand_list"
    end
  end

  def city_list
    @title = "城市列表"
    @cities = City.paginate :order => "id", :per_page => 30, :page => params[:page]
  end

  def recommend_edit
    unless params[:id].blank?
      @title = "修改推荐"
      @recommend = RecommendHistory.find(params[:id])
    else
      @title = "添加推荐"
      @demand = ContactDemand.find(params[:demand_id])
      @recommend = RecommendHistory.new(:contact_demand_id => @demand.id, :firm_id => @demand.firm_id)
      unless params[:contact_id].blank?
        @contact = Contact.find(params[:contact_id])
        @recommend.contact_id = @contact.id
      end
    end
    @firm = @recommend.firm
  end

  def recommend_update
    user = current_user
    unless params[:id].blank?
      @recommend = RecommendHistory.find(params[:id])
      @recommend.update_attributes(params[:recommend_history].merge(:updated_by => user.id))
    else
      @recommend = RecommendHistory.create(params[:recommend_history].merge(:updated_by => user.id,
                                                                            :created_by => user.id, :status_id => 1))
    end
    if @recommend.errors.empty?
      flash[:notice] = "成功保存！"
      redirect_to :action => "recommend_view", :controller => params[:db_type], :id => @recommend.id, :format => 'php'
    else
      @title = params[:id].blank? ? "添加推荐" : "修改推荐"
      @firm = @recommend.firm
      render :action => "recommend_edit"
    end
  end

  def recommend_view
    @title = "推荐记录"
    user = current_user
    @recommend = RecommendHistory.find(params[:id])
    @contact = @recommend.contact
    @cur_firm = @contact.firm
    @demand = @recommend.contact_demand
    @req_firm = @demand.firm

    @can_edit = ((@recommend.recommend?&&@req_firm.res_followed_by?(user)) or current_user.is_admin?)
    @can_follow = @req_firm.sales_followed_by?(user)
    render :template => "/sales/recommend_view"
  end

  alias recommend_show recommend_view

  def recommend_destroy
    recommend = RecommendHistory.find(params[:id])
    recommend.destroy
    flash[:notice] = "成功删除！"
    redirect_to :action => "demand_view", :controller => params[:db_type], :id => self.contact_demand_id, :format => 'php'
  end

  def change_recommend_status
    recommend = RecommendHistory.find(params[:id])
    recommend.update_attribute('status_id', params[:status_id])
    flash[:notice] = "操作成功！"
    redirect_to :action => "recommend_view", :controller => params[:db_type], :id => recommend.id, :format => 'php'
  end

  def get_cities
    @cities = City.get_cities(params[:id]).map { |c| [c.name_cn, c.id] }
    render :template => "/common/get_cities", :layout => false
  end

  def get_positions
    @positions = ContactPosition.get_positions(params[:id]).map { |c| [c.name, c.id] }
    render :template => "/common/get_positions", :layout => false
  end

  def submit_order
    @title = "提交订单"
    if params[:firm_id].blank? and @order.blank?
      render :text => "参数错误，请从公司详细页面点击“提交订单按钮。”", :layout => false
    end
    @order = Order.new(:firm_id => params[:firm_id]) if @order.blank?
    if request.post?
      @order.attributes = params[:order]
      @order.employee_id = current_user.id
      if @order.valid?
        @order.save
        redirect_to :action => "firm_show", :id => params[:firm_id], :format => "php"
      else
        render :action => :submit_order
      end
    end
  end

  def my_orders
    @title = "我提交的订单"
    if current_user.is_admin?
      @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }
    end
    order_hash = params[:order]||{}
    order_ary = Order.get_sql_by_hash(order_hash)

    join = params[:firm_name].blank? ? "" : "left join firms on firms.id = orders.firm_id"
    @orders = Order.paginate :select => "orders.*", :conditions => order_ary,
                             :joins => join, :order => "created_at desc", :per_page => 30, :page => params[:page]
  end

  protected

  def init_menu
    params[:db_type]||="crm"

    @sys_title = (crm_sys? ? "销售系统" : "顾问系统")
    user = current_user

    if crm_sys?
      @sys_nav_menus = [['/crm/search', '公司搜索'], ['/crm/my_firms/', '我的公司'], ['/crm/firm_edit/', '添加公司'], ['/crm/my_recall', '我的跟进任务'],
                        ['/crm/demand_list', '招聘需求列表']]
    else
      @sys_nav_menus = [['/res/search', '资源搜索'], ['/res/my_firms/', '我的资源'], ['/res/firm_edit/', '添加公司'], ['/res/my_recall', '我的跟进任务'],
                        ['/res/demand_list', '招聘需求列表'], ['/res/my_orders/', '我提交的订单']]
    end
    @sys_nav_menus << ['/res/contact_list', '候选人列表'] if user.is_res?


  end

  def crm_sys?
    params[:db_type]=="crm"
  end

  def res_sys?
    params[:db_type]=="res"
  end

  def preload_demand_edit
    @firm = @demand.firm
    load_firm_types @demand.firm_type_id
    preload_regions @demand.province_id
  end

  def preload_firm_edit
    @firm_types = FirmType.all(:order => "id").map { |t| [t.name, t.id] }
    preload_regions(@firm.province_id)
    @foreign_types = Firm::FOREIGN_TYPES
  end

  def preload_contact_edit
    @firm = @contact.firm
    load_firm_types @contact.firm_type_id
    @exp_positions = @contact.expect_firm_type_id.blank? ? [['请先选择职业类别', '']] :
        ContactPosition.get_positions(@contact.expect_firm_type_id).map { |p| [p.name, p.id] }
    @salary_types = Contact::SALARY_TYPES
    preload_regions(@contact.province_id)
  end

  def load_firm_types(firm_type_id)
    @firm_types = FirmType.all(:order => "id").map { |t| [t.name, t.id] }
    @positions = firm_type_id.blank? ? [['请先选择职业类别', '']] : ContactPosition.get_positions(firm_type_id).map { |p| [p.name, p.id] }
  end

  def preload_regions(province_id)
    @countries = Country.get_all_countries
    @provinces = Province.get_provinces.map { |p| [p.name_cn, p.id] }
    @cities = province_id.blank? ? [['请先选择省份', '']] : City.get_cities(province_id).map { |c| [c.name_cn, c.id] }.unshift(['', ''])
  end

  def preload_recall
    @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }
    @recall ||= Recall.new(:firm_id => @firm&&@firm.id, :contact_id => @contact&&@contact.id,
                           :employee_id => current_user.id, :contact_by_id => 1)
    case params[:action]
      when 'firm_show', 'firm_view'
        contacts = @firm.contacts
        obj = @firm
      when 'contact_show', 'contact_view'
        contacts = [@contact]
        obj = @contact
      when 'recall_edit'
        firm = @recall.firm
        contacts = firm.contacts
        obj = firm
    end
    @contacts = contacts.compact.map { |c| [c.full_name(true, true), c.id] }

    @pending_calls = obj.recalls.dep_recalls(current_user.department_id).where("completed_at is null").order("appt_date desc").limit(5)
    @com_calls = obj.recalls.dep_recalls(current_user.department_id).where("completed_at is not null").order("appt_date desc").limit(5)
  end

end
