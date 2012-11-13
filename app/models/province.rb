#encoding:utf-8
class Province < ActiveRecord::Base
  def self.get_provinces(country_id=8)
    Province.find(:all, :conditions=>["country_id = ?", country_id], :order=>"name")
  end

  def to_s
    self.name_cn
  end

end
