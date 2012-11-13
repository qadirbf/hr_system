#encoding:utf-8
class City < ActiveRecord::Base

  def self.get_cities(prov_id)
    city_type = City.city_type(prov_id.to_i)
    City.find(:all, :order=>"name", :conditions=>["province_id=? and city_type=?", prov_id, city_type])
  end

  def self.city_type(prov_id, cheng_du_mode=false)
    if cheng_du_mode
      ([3, 15, 32, 19].include?(prov_id) ? 2 : 1)
    else
      ([3, 15, 32, 19].include?(prov_id) ? 2 : 1)
    end
  end

  def to_s
    self.name_cn
  end

end
