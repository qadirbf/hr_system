class LoginHistory < ActiveRecord::Base
  def self.add_history(username,pwd,eid,sid,ip,failed)
    self.create(:username=>username,:pwd=>pwd,:employee_id=>eid,:ip=>ip,:failed=>failed,:session_id=>sid)
  end
end
