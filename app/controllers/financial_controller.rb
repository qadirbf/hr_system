#encoding:utf-8
class FinancialController < ApplicationController
  before_filter :check_right

  def order_list
    @title = "订单列表"
    @emps = Employee.active_emps.select('id,username').order("username").map { |e| [e.username, e.id] }

    order_hash = params[:order]||{}
    _sql, p_hash = Order.get_sql_by_hash(order_hash)
    sql = [_sql]

    joins = params[:firm_name].blank? ? "" : "left join firms on firms.id = orders.firm_id"
    unless params[:firm_name].blank?
      sql << "firms.firm_name like :firm_name"
      p_hash.merge!({:firm_name => "%#{params[:firm_name]}%"})
    end

    unless params[:share_order_employee].blank?
      sql << " share_orders.employee_id = :share_emp "
      p_hash.merge!({:share_emp => params[:share_order_employee]})
      joins += " left join share_orders on share_orders.order_id = orders.id "
    end

    sql.delete_if { |s| s.blank? }

    @orders = Order.paginate :select => "orders.*", :conditions => [sql.join(" AND "), p_hash],
                             :joins => joins, :order => "created_at desc", :per_page => 30, :page => params[:page]

    start_time = order_hash[:credited_date_gte].blank? ? "#{Time.now.year}-01-01 00:00:00" : order_hash[:credited_date_gte]
    end_time = order_hash[:credited_date_lte].blank? ? Time.now.strftime("%Y-%m-%d 23:59:59") : order_hash[:credited_date_lte]
    @total_money = Order.find_by_sql("select sum(total_amount) as money from orders where credited_date between '#{start_time}' and '#{end_time}'").first.try(:money)
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
    sql.delete_if { |s| s.blank? }

    @employees = Employee.find_by_sql("select employees.* from employees right join share_orders on share_orders.employee_id = employees.id " + (f.blank? ? '' : "where #{f}"))

    @share_orders = ShareOrder.all :select => "share_orders.*", :conditions => [sql.join(" AND "), p_hash],
                                   :joins => joins, :order => "created_at desc"
  end

  def check_right
    unless current_user.is_admin?
      render :text => "没有权限访问该页面"
    end
  end

  def init_menu
    @sys_nav_menus = []
    @sys_nav_menus << ['/financial/order_list', '订单列表']
    @sys_nav_menus << ['/financial/order_count', '订单统计']
  end
end
