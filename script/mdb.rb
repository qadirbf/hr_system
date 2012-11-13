#encoding: utf-8
["建材类","开发商/总包方","设计院类"].each{|n| FirmType.create(:name=>n)}
#%w{销售总监 市场总监 技术总监 产品总监 综合管理 区域经理}.each{|n| ContactPosition.create(:firm_type_id=>1,:name=>n)}
#%w{销售总监 市场总监  技术总监 产品总监 采购总监 设计总监 综合管理}.each{|n| ContactPosition.create(:firm_type_id=>2,:name=>n)}
#%w{室内设计师 结构设计师 建筑设计师 暖通设计师 弱电设计师 设计总监}.each{|n| ContactPosition.create(:firm_type_id=>3,:name=>n)}