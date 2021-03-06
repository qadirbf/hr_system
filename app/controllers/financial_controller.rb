#encoding:utf-8
class FinancialController < ApplicationController
  before_filter :check_right

  def order_list
    @title = "订单列表"
    firm_types = EmployeesFirmType.where("employee_id = #{current_user.id}").select("firm_type_id").collect(&:firm_type_id)
    emps = EmployeesFirmType.where("firm_type_id in (?)", firm_types).select("distinct employee_id").collect(&:employee_id)
    @emps = Employee.active_emps.where("id in (?)", emps).select('id,username').order("username").map { |e| [e.username, e.id] }

    order_hash = params[:order]||{}
    _sql, p_hash = Order.get_sql_by_hash(order_hash)
    sql = [_sql]

    joins = params[:firm_name].blank? ? "" : "left join firms on firms.id = orders.firm_id"
    unless params[:firm_name].blank?
      sql << "firms.firm_name like :firm_name"
      p_hash.merge!({:firm_name => "%#{params[:firm_name]}%"})
    end

    joins += " left join share_orders on share_orders.order_id = orders.id "
    if current_user.right_level > 2
      sql << "share_orders.employee_id in (:emps)"
      p_hash.merge!(:emps => emps)
    else
      sql << " share_orders.employee_id = :share_emp "
      share_emp = current_user.is_admin? ? params[:share_order_employee] : current_user.id
      p_hash.merge!({:share_emp => share_emp})
    end

    sql.delete_if { |s| s.blank? }

    if current_user.is_admin? and current_user.is_partner?
      sql << "orders.created_at >= '2014-01-01 00:00:00'"
    end

    @orders = Order.paginate :select => "distinct orders.*", :conditions => [sql.join(" AND "), p_hash],
                             :joins => joins, :order => "created_at desc", :per_page => 30, :page => params[:page]

    #start_time = order_hash[:credited_date_gte].blank? ? "#{Time.now.year}-01-01 00:00:00" : order_hash[:credited_date_gte]
    start_time = order_hash[:credited_date_gte].blank? ? "2013-01-01 00:00:00" : order_hash[:credited_date_gte]
    end_time = order_hash[:credited_date_lte].blank? ? Time.now.strftime("%Y-%m-%d 23:59:59") : order_hash[:credited_date_lte]
    if current_user.is_partner?
      @credited_money = Order.find_by_sql("select sum(total_amount) as money from orders where orders.created_at >= '2014-01-01 00:00:00' and credited_date between '#{start_time}' and '#{end_time}' and (status_id in (2,3) and (count_in != 0))").first.try(:money).to_f
      @uncredited_money = Order.find_by_sql("select sum(total_amount) as money from orders where orders.created_at >= '2014-01-01 00:00:00' and created_at between '#{start_time}' and '#{end_time}' and status_id = 1").first.try(:money).to_f
    else
      @credited_money = Order.find_by_sql("select sum(total_amount) as money from orders where credited_date between '#{start_time}' and '#{end_time}' and (status_id in (2,3) and (count_in != 0))").first.try(:money).to_f
      @uncredited_money = Order.find_by_sql("select sum(total_amount) as money from orders where created_at between '#{start_time}' and '#{end_time}' and status_id = 1").first.try(:money).to_f
    end
  end

  # 订单统计
  def order_count
    @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }

    order_hash = params[:order]||{}
    _sql, p_hash = Order.get_sql_by_hash(order_hash)
    sql = [_sql]
    f = ''
    unless params[:employee_id].blank?
      sql << " share_orders.employee_id = :share_emp "
      p_hash.merge!({:share_emp => params[:employee_id]})
      f = "employees.id = #{params[:employee_id]}"
    end
    joins = " left join orders on orders.id = share_orders.order_id"
    sql << " (orders.add_to is null or orders.add_to = 1) "
    sql.delete_if { |s| s.blank? }

    @employees = Employee.find_by_sql("select distinct employees.* from employees right join share_orders on share_orders.employee_id = employees.id " + (f.blank? ? '' : "where #{f}"))

    @share_orders = ShareOrder.all :select => "share_orders.*", :conditions => [sql.join(" AND "), p_hash],
                                   :joins => joins, :order => "created_at desc"
  end

  # 修改订单
  def edit_order
    @title = "修改订单"
    @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }
    @order = Order.where("id = #{params[:id]}").first
    if params[:id].blank? and @order.blank?
      render :text => "参数错误，请从订单列表页面点击“修改”", :layout => false
    end

    firm = Firm.where("id=#{@order.firm_id}").first
    #@candidates = firm.all_candidates.map { |c| [c.full_name, c.id] }
    @demands = firm.contact_demands.map { |c| [c.position_type_text, c.id] }
    tmp = @order.share_orders.map { |s| [s.employee_id, s.percentage, s.money].join('-') }
    @share_orders = tmp.join(";")
  end

  def update_order
    @order = Order.where("id = #{params[:id]}").first
    @order.attributes = params[:order]
    @order.employee_id = current_user.id
    if @order.valid?
      @order.credited_date = nil if @order.status_id == 1
      @order.save
      share = params[:share]
      ary = []
      (1..5).each do |i|
        if !share["employee_id_#{i}"].blank? and !share["percentage_#{i}"].blank?
          ary << i
        end
      end
      @order.share_orders.each { |s| s.destroy }
      ary.each do |i|
        ShareOrder.create!({:order_id => @order.id, :employee_id => share["employee_id_#{i}"], :created_by => current_user.id,
                            :percentage => share["percentage_#{i}"], :money => (@order.total_amount * share["percentage_#{i}"].to_i / 100)})
      end
      # 如果是补充招聘的订单
      OtherOrder.delete_all("order_id = #{@order.id}")
      unless @order.status_id == 3
        params[:other_no].split(/,|;/).each do |o|
          if o.to_i > 0
            order = Order.where("id = #{o}").first
          else
            order = Order.where("order_no = '#{o}'").first
          end

          unless order.blank?
            OtherOrder.create({:order_id => @order.id, :added_order_id => order.id})
          end
        end
      end
      redirect_to :action => "order_list", :format => "php"
    else
      #firm = Firm.where("id=#{@order.firm_id}").first
      @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }
      @demands = @order.firm.contact_demands.map { |c| [c.position_type_text, c.id] }
      tmp = @order.share_orders.map { |s| [s.employee_id, s.percentage, s.money].join('-') }
      @share_orders = tmp.join(";")
      render :action => :edit_order
    end
  end

  ##删除订单，需要先删除分单
  #def delete_order
  #  Order.transaction do
  #    begin
  #      ShareOrder.delete_all("order_id = #{params[:id]}")
  #      Order.delete_all("id = #{params[:id]}")
  #    rescue => e
  #      raise "Error！#{e.message}"
  #    end
  #    redirect_to :action => "order_list"
  #  end
  #end

  def check_right
    unless current_user.right_level > 3
      render :text => "没有权限访问该页面"
    end
  end

  def init_menu
    @sys_nav_menus = []
    @sys_nav_menus << ['/financial/order_list', '订单列表']
    @sys_nav_menus << ['/financial/order_count', '订单统计']
  end
end
