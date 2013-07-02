require 'iconv'

convert = Iconv.new('UTF-8//IGNORE', 'GB2312//IGNORE')

def write_to_db(data)
  return false if data.size==0

  OtherCandidate.transaction do
    data.each do |d|
      c = OtherCandidate.new(:name=>d[1], :sex=>d[2], :birth=>d[3], :city=>d[4])
      c.hukou = d[5]
      c.salary = d[6]
      c.work_year = d[7]
      c.address = d[8]
      c.postcode = d[9]
      c.email = d[10]
      c.home_tel = d[12]
      c.work_tel = d[13]
      c.mobile = d[11]
      c.website = d[14]
      c.industry = d[16]
      c.location = d[17]
      c.job_post = d[19]
      c.remarks = d[20]
      c.source = "51job"
      c.save
    end
  end
end

File.open("51job.csv") do |file|
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