#encoding:utf-8
module DailyController

  def my_daily
    @title = "我的日报"
    @dailies = Daily.paginate :conditions => "", :per_page => 20, :page => params[:page]
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

  def daily_update

  end

  def auto_object
    key = params[:q] if params[:q]
    @results = Firm.where("firm_name like '%#{key}%'").all

    render :template => "sales/auto_firm"
  end

end
