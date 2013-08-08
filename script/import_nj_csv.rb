require 'iconv'

convert = Iconv.new('UTF-8//IGNORE', 'GB2312//IGNORE')

def write_to_db(data)
  return false if data.size==0
  province = Province.where("name_cn like '%江苏%'").first
  province_id = province.try(&:id)

  OtherCandidate.transaction do
    data.each do |d|
      c = OtherCandidate.new(:name=>d[2], :city=> "南京市")
      age = Time.now.year - d[4].to_i
      c.age = age
      c.province_id = province_id
      c.sex = (d[3].to_i == 1 ? "男" : "女")       #sex
      c.birth = [d[4], d[5]].join("-")
      c.email = d[1]
      c.address = d[12]
      c.postcode = d[11]
      c.mobile = (d[8].blank? ? "" : d[8].split("|").last)
      c.industry = d[19]
      c.remarks = d[20]
      c.source = "51job"
      c.save
    end
  end
end

File.open("sznj.csv") do |file|
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