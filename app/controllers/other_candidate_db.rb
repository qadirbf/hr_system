#encoding: utf-8
module OtherCandidateDb

  def other_db_list
    @title = "补充资源库"

    params[:page]||=1

    scope = OtherCandidate

    unless params[:province_id].blank?
      scope = scope.where(["province_id = ?", params[:province_id]])
    end

    unless params[:keyword].blank?
      scope = scope.where(["job_post like :keyword or industry like :keyword or remarks like :keyword", {:keyword=>"%#{params[:keyword]}%"}])
    end

    unless params[:contact].blank?
      scope = scope.where(["email like :contact or mobile like :contact or home_tel like :contact or work_tel like :contact", {:contact=>"%#{params[:contact]}%"}])
    end

    @candidates = scope.paginate :order => "created_at desc", :per_page => 30, :page => params[:page]

  end

  def other_db_show
    @candidate = OtherCandidate.find(params[:id])
    @title = "补充资源库 - #{@candidate.name}"
  end

end