#encoding:utf-8
module ApplicationHelper

  def open_link(label,url,opts={})
    link_to label,"javascript:void(0)",opts.merge(:onclick=>"open_url('#{url}')")
  end

  def open_firm_page(text, id)
    link_to_function text, "open_url('/#{params[:db_type]}/firm_show.php?id=#{id}')"
  end

  def open_contact_page(text, id)
    link_to_function text, "open_url('/#{params[:db_type]}/contact_show.php?id=#{id}')"
  end

  def open_demand_page(text, id)
    link_to_function text, "open_url('/#{params[:db_type]}/demand_view.php?id=#{id}')"
  end

  def candidate_label(contact)
    content_tag("span", "候选人", :class=>"label label-info") if contact.is_candidate?
  end

  def protect_label(contact, firm_id)
    content_tag("span", "已保护", :class=>"label-pt") if contact.is_protected?(firm_id)
  end

  def errors_for(obj)
    errors = obj.errors.messages.values.flatten.map{|v| "* #{v}"}
    return '' unless errors.size>0
    %{<div class="alert alert-error">#{errors.join("<br>")}</div>}.html_safe
  end

  def format_date(date,type)
    case type
      when :full
        (date ? date.strftime("%Y-%m-%d %H:%M:%S") : "")
      when :min
        (date ? date.strftime("%Y-%m-%d %H:%M") : "")
      when :date
        (date ? date.strftime("%Y-%m-%d") : "")
      when :mon
        (date ? date.strftime("%Y-%m") : "")
      when :year
        (date ? date.strftime("%Y") : "")
      when :quarter
        (date ? [date.strftime("%Y"), "年", [["第一", "第二", "第三", "第四"][(date.month-1)/3], "季度"]].join : "")
      when :expired
        (date ? (date>Time.now ? "未到期" : "已到期") : "")
    end
  end

  def include_datepicker
    render :partial=>"/common/datepicker"
  end

  def include_nav_box_js
    render :partial=>"/common/nav_box_js"
  end

  def url_with_session(link)
    return link if !link
    l = link.split("/")-[""]
    if l.size==1
      url_for :controller=>l[0], :action=>"index", :id=>nil
    elsif l.size==2
      return link if l[1].include?("?")
      url_for :controller=>l[0], :action=>l[1], :id=>nil
    else
      return link
    end
  end

  def page_links(obj)
    will_paginate obj,:params=>page_params(params),:previous_label=>"<<", :next_label=>">>"
  end

  def page_params(p)
    p||={}
    pa = Hash.new
    p.each { |k, v|
      pa[k] = v if k!='controller'&&k!='page'&&k!='action'
    }
    pa
  end

end
