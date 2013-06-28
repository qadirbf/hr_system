#encoding:utf-8
module DailyController

  def my_daily
    @title = "我的日报"
    @dailies = Daily.paginate :conditions => "", :per_page => 20, :page => params[:page]
    render :template => "/daily/my_daily"
  end

end
