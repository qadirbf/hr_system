#encoding:utf-8
class FirmLead < ActiveRecord::Base
  belongs_to :firm
  belongs_to :employee

  def grab_by(emp_id)
    user = Hr.user
    if user.id==self.employee_id||self.employee_id==0||user.is_admin?
      old_emp_id = self.employee_id
      transaction do
        hash = {:employee_id => emp_id, :grab_date => Time.now, :updated_by => user.id}
        hash.merge!(:created_by => user.id) if self.new_record?
        hash.each { |k, v| self.send("#{k.to_s}=", v) }
        self.save

        add_history old_emp_id, emp_id
        unless old_emp_id.blank?
          self.firm.contacts.update_all(["employee_id = ?", (emp_id==0 ? nil : emp_id)], ["employee_id = ?", old_emp_id])
        end

        unless emp_id==0
          Recall.dep_recalls(user.department_id).update_all(
              ["employee_id=?,recalls.updated_by=?,recalls.updated_at=now()", emp_id, user.id],
              ["firm_id=? and completed_at is null", self.firm_id])
        end
      end
    else
      raise RightError, "没有权限!"
    end
  end

  def grab_user_info
    return "空置" if self.employee_id==0
    return [self.emp.username, self.grab_date.format_date(:date)].join(' - ')
  end

  def emp
    self.employee||Employee.new(:username => "空置")
  end

  protected

  def add_history(old_emp_id, emp_id)
    hash = {:firm_id => self.firm_id, :leads_type_id => self.leads_type_id, :old_emp_id => old_emp_id, :employee_id => emp_id,
            :grab_date => self.grab_date, :created_by => Hr.user.id}
    LeadsHistory.create(hash)
  end

end
