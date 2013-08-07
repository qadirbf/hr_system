require 'iconv'

convert = Iconv.new('UTF-8//IGNORE', 'GB2312//IGNORE')

def write_to_db(data)
  return false if data.size==0
  province = Province.where("name_cn like '%上海%'").first
  province_id = province.try(&:id)
  OtherCandidate.transaction do
    data.each do |d|
      c = OtherCandidate.new(:name=>d[2], :birth=>d[3], :city=> "上海市")
      year = d[3].split(/\//).first.to_i
      age = Time.now.year - year
      c.age = age
      c.province_id = province_id
      c.work_year = d[6]
      c.email = d[1]
      c.mobile = (d[5].blank? ? "" : d[5].split("|").last)
      c.industry = d[11]
      c.source = "51job"
      c.save
    end
  end
end

File.open("sh.csv") do |file|
  current_line = 1
  data = []
  file.each_line do |line|
    data << convert.iconv(line).split(',').map{|s| s.gsub('"', "")}
    current_line += 1
    if current_line % 500==0
      puts current_line
      write_to_db data
      data = []
    end
  end

end