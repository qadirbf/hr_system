#encoding: utf-8
module OtherCandidateDb

  def other_db_list
    @title = "补充资源库"

    params[:page]||=1

    ary = ["1=1"]
    p_hash = {}

    unless params[:province_id].blank?
      #scope = scope.where(["province_id = ?", params[:province_id]])
      ary << "province_id = :province_id"
      p_hash.merge!({:province_id => params[:province_id]})
    end

    unless params[:keyword].blank?
      #scope = scope.where(["job_post like :keyword or industry like :keyword or remarks like :keyword", {:keyword=>"%#{params[:keyword]}%"}])
      ary << "(job_post like :keyword or industry like :keyword or remarks like :keyword)"
      p_hash.merge!({:keyword => params[:keyword]})
    end

    unless params[:contact].blank?
      #scope = scope.where(["email like :contact or mobile like :contact or home_tel like :contact or work_tel like :contact", {:contact=>"%#{params[:contact]}%"}])
      ary << "(email like :contact or mobile like :contact or home_tel like :contact or work_tel like :contact)"
      p_hash.merge!({:contact => params[:contact]})
    end

    unless params[:sex].blank?
      ary << " sex = :sex"
      p_hash.merge!({:sex => params[:sex]})
    end

    @candidates = OtherCandidate.paginate :conditions => [ary.join(" and "), p_hash], :order => "created_at desc", :per_page => 30, :page => params[:page]

  end

  def other_db_show
    @candidate = OtherCandidate.find(params[:id])
    @title = "补充资源库 - #{@candidate.name}"
  end

  def export_source_to_excel
    ary = ["1=1"]
    p_hash = {}

    unless params[:province_id].blank?
      ary << "province_id = :province_id"
      p_hash.merge!({:province_id => params[:province_id]})
    end

    unless params[:keyword].blank?
      ary << "(job_post like :keyword or industry like :keyword or remarks like :keyword)"
      p_hash.merge!({:keyword => params[:keyword]})
    end

    unless params[:contact].blank?
      ary << "(email like :contact or mobile like :contact or home_tel like :contact or work_tel like :contact)"
      p_hash.merge!({:contact => params[:contact]})
    end

    unless params[:sex].blank?
      ary << " sex = :sex"
      p_hash.merge!({:sex => params[:sex]})
    end

    @candidates = OtherCandidate.all :conditions => [ary.join(" and "), p_hash], :order => "created_at desc"
    send_data(xls_content_for(@candidates),
              :type => "text/excel;charset=utf-8; header=present",
              :filename => "#{Time.now.strftime("%Y-%m-%d")}简历库.xls")
  end

  private
  def xls_content_for(objs)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "简历"

    blue = Spreadsheet::Format.new :color => :blue, :weight => :bold, :size => 10
    sheet1.row(0).default_format = blue

    sheet1.row(0).concat %w{姓名 性别 生日 城市 户口 目前工资 工作经验 联系地址 邮编 邮箱 手机 家庭电话 工作电话 期望行业 期望工作地点 期望职位 备注 }
    count_row = 1
    objs.each do |obj|
      user = obj.user
      sheet1[count_row, 0]= user.name
      sheet1[count_row, 1]= user.sex
      sheet1[count_row, 2]= user.birth
      sheet1[count_row, 3]= user.city
      sheet1[count_row, 4]= user.hukou
      sheet1[count_row, 5]= user.salary
      sheet1[count_row, 6]= user.work_year
      sheet1[count_row, 7]= user.address
      sheet1[count_row, 8]= user.postcode
      sheet1[count_row, 9]= user.email
      sheet1[count_row, 10]= user.mobile
      sheet1[count_row, 11]= user.home_tel
      sheet1[count_row, 12]= user.work_tel
      sheet1[count_row, 13]= user.industry
      sheet1[count_row, 14]= user.location
      sheet1[count_row, 15]= user.job_post
      sheet1[count_row, 16]= user.remarks
      count_row += 1
    end
    book.write xls_report
    xls_report.string
  end

end