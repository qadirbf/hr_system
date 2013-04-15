#encoding:utf-8
class FinancialController < ApplicationController

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

    sql.delete_if{|s| s.blank?}

    @orders = Order.paginate :select => "orders.*", :conditions => [sql.join(" AND "), p_hash],
                             :joins => joins, :order => "created_at desc", :per_page => 30, :page => params[:page]
  end

  def init_menu
    @sys_nav_menus = []
    @sys_nav_menus << ['/financial/order_list', '订单列表']
  end
end
