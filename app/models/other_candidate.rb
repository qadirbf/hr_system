#encoding:utf-8
class OtherCandidate < ActiveRecord::Base
  attr_accessible :address, :birth, :city, :city_id, :education, :email, :home_tel,
                  :hukou, :id_card, :industry, :industry_code, :job_post, :location,
                  :mobile, :name, :postcode, :remarks, :salary, :sex, :website, :work_tel, :work_year
end
