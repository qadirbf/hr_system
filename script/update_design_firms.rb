#encoding: utf-8
puts 'begin update firms...'
firm_type_id = FirmType.where("name like '%设计%'").first.try(:id)
Firm.transaction do
  begin
    Firm.update_all("firm_type_id = #{firm_type_id}", "firm_name like '%设计%'")
    Firm.update_all("firm_type_id = #{firm_type_id}", "firm_name like '%研究%'")
    Firm.update_all("firm_type_id = #{firm_type_id}", "firm_name like '%事务%'")
  rescue => e
    puts "Error! #{e.message}"
  end
end
puts "更新成功"