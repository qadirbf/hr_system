#encoding: utf-8
num = 0
OtherCandidate.find_each(:conditions => "age is null and province_id is null") do |c|
  num += 1
  # update age
  year = c.birth.split(/年|月|日/).first.to_i
  age = Time.now.year - year
  tmp_city = c.city
  city_name = tmp_city[0, 2]
  province = Province.where("name_cn like '%#{city_name}%'").first
  unless province.blank?
    province_id = province.id
  else
    city = City.where("name_cn like '%#{city_name}%'").first
    province_id = city.try(&:province_id)
  end
  c.update_attributes({:province_id => province_id, :age => age})
  puts num if num % 500 == 0
end
