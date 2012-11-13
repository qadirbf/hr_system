#encoding:utf-8
class Country < ActiveRecord::Base

  def self.get_all_countries(include_blank = false)
    countries = Country.find(:all, :order=>"abbv", :conditions=>"name_cn is not null")
    if include_blank
      array = [["快速选择", [["", ""], ["中国", 8]]]]
    else
      array = [["快速选择", [["中国", 8]]]]
    end

    countries.map { |c| c.abbv[0,1] }.uniq.sort.each do |abbv|
      abbv_countries = countries.find_all { |c| c.abbv[0,1]==abbv }
      array << [abbv, abbv_countries.map { |c| [(c==abbv_countries.first ? [abbv, c.name_cn].join('.') : c.name_cn), c.id] }]
    end

    array
  end

end
