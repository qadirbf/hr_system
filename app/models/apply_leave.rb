#encoding:utf-8
class ApplyLeave < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :employee
  belongs_to :created_user, :class_name => "Employee", :foreign_key => "created_by"
  belongs_to :updated_user, :class_name => "Employee", :foreign_key => "updated_by"
  belongs_to :apply_manager, :class_name => "Employee", :foreign_key => "apply_to"
  belongs_to :apply_hr, :class_name => "Employee", :foreign_key => "apply_to_hr"
  validates_presence_of :employee_id, :message => "请选择申请员工"
  validates_presence_of :deponent, :message => "没有输入证明人，或输入的证明人不存在！",
                        :if => Proc.new { |apply| [14, 17].include?(apply.absence_reason) }

  ABSENCE_REASON = [["普通事假", 2], ["特殊事假", 18], ["年假", 3], ["病假", 4], ["出差", 5], ["产检", 6], ["产假", 7], ["婚假", 8], ["丧假", 9], ["调休", 10], ["因公外出", 11],
                    ["因不可抗力上班未打卡", 12], ["因不可抗力下班未打卡", 16], ["加班", 13], ["上班忘记打卡", 14], ["下班忘记打卡", 17], ["哺乳假", 15]]
  OUT_TYPES = [["拜访客户", 0], ["设计院", 1], ["采购", 2], ["处理公司事务", 3], ["其他", 4]]
  STATUS = [["草稿", 0], ["等待人事审核", 1], ["人事审核完毕", 2], ["等待队长/经理审核", 3], ["已批准", 4], ["已拒绝", 5], ["已取消", 6]]
  LEAVE_TIME = [['2小时', 0.25], ['半天', 0.5], ['6小时', 0.75], ['一天', 1]]
  STATUS_ARR = [["is_draft?", 0], ["hr_check_stage?", 1], ["hr_has_checked?", 2], ["manager_check_stage?", 3], ['was_approved?', 4], ['was_refused?', 5], ['was_canceled?', 6]]
  FEED_TYPES = [["晚到1小时", 1], ["中午1小时(13:00~14:00)", 3], ["早走1小时", 2]]

  STATUS_ARR.each do |arr|
    module_eval %{
      def #{arr[0]}
        self.status == #{arr[1]}
      end
    }
  end

  include HrLib::Functions
  include HrLib::BaseAttendance

  def submit_by_others?
    self.employee_id != self.created_by
  end

  def not_record_attendance?
    [12, 16, 14, 17].include?(self.absence_reason)
  end

  def need_feed?
    self.absence_reason == 15
  end

  def can_apply_cancel?
    self.was_approved? && self.apply_cancel != 1 && self.employee_id == Hr.user.id
  end

  def can_apply_back?
    self.back_reason.blank?&&!self.is_draft? && !self.was_canceled? && self.employee_id == Hr.user.id
  end

  def need_manager_cancel?
    self.was_approved? && self.apply_cancel == 1 && self.apply_to == Hr.user.id
  end

  def status_label
    get_array_type_text STATUS, self.status
  end

  def absence_label
    get_array_type_text ABSENCE_REASON, self.absence_reason
  end

  def deponent_text=(text='')
    results = []
    text.gsub!(/[\s\r\n]*/, "").gsub!('，', ',')
    text.downcase.split(',').each do |username|
      employee = Employee.find_by_username(username)
      results << employee.id if employee
    end
    self.deponent = results.uniq.join(',')
  end

  def deponent_text
    return nil if self.deponent.blank?
    Employee.all(:select => "username", :conditions => ["id in (?)", self.deponent.split(',')], :order => "username").map { |e| e.username }.join(',')
  end

  def start_date_label
    return "" if self.start_date.blank?
    return self.start_date.format_date(:date) if self.not_record_attendance?||self.need_feed?
    return self.start_date.format_date(:min)
  end

  def approval_managers
    [Employee.where("id=1").first]
  end

  def send_message_for_apply
    employee = self.employee
    to_id = self.hr_check_stage? ? self.apply_to_hr : self.apply_to
    subject = "#{employee.username}(#{employee.name_cn})提交了申请，需要您审批"
    body = %{<a href='/attendance/apply_leave_show?id=#{self.id}'>#{subject}</a><br>
          申请时间：#{Time.now.format_date(:full)}}
    EmpMsg.send_msg(employee.id, to_id, subject, body)
  end

  def send_message_for_apply_cancel_to_manager
    employee = self.employee
    subject = "#{employee.username}(#{employee.name_cn})希望取消申请，需要您批准"
    body = %{#{subject}<br><a href='/attendance/apply_leave_show?id=#{self.id}'>点击这里查看详细信息</a>}
    EmpMsg.send_message(employee.id, self.apply_to, subject, body)
  end

  def notes_label
    label_hash = {"out_reason" => "事由", "org_name" => {'0' => "客户名称", '1' => "设计院名称", '2' => "供应商", '3' => "事务办理机构名称", '4' => '事务办理机构名称'},
                  "address" => "地址", "contact_name" => "联系人", "contact_method" => "联系方式", "expect_time" => "预计时间"}
    notes = YAML.load(self.leave_notes||' ')
    arr = []
    if notes.class.name.downcase.include?('hash')
      out_type_id = notes["out_type"].to_i
      notes.each do |key, value|
        t_arr = []
        if key=='org_name'
          t_arr << label_hash['org_name'][out_type_id.to_s]
          t_arr << value
        elsif key=='out_type'
          t_arr << '外出类型'
          t_arr << ApplyLeave::OUT_TYPES.inject(nil) { |r, t| r||(t[0] if t[1]==out_type_id) }
        else
          t_arr << label_hash[key]
          t_arr << value
        end
        arr << t_arr
      end
      notes = arr.map { |a| a.join('：') }.join("\r\n")
    end
    return notes||''
  end

  def get_send_msg_to
    [1]
  end

  def leave_days
    return 0 if self.start_date.blank?||self.end_date.blank?
    return ((self.end_date - self.start_date)/24/3600 + 1)*0.125 if self.need_feed?
    sum = 0.0
    if self.start_date.format_date(:date) == self.end_date.format_date(:date)
      sum = self.class.get_leave_time(self.start_date, self.end_date)
    else
      sum = self.class.get_leave_time(self.start_date, self.class.end_of_work_day(self.start_date)) unless [0, 6].include?(self.start_date.wday) #&&self.include_weekend!=1
      t_time = self.start_date + 1.day
      while t_time <= (self.end_date-1.day).end_of_day
        sum += 1 unless [0, 6].include?(t_time.wday) #&&self.include_weekend!=1
        t_time += 1.day
      end
      sum += self.class.get_leave_time(self.class.beginning_of_work_day(self.end_date), self.end_date) unless [0, 6].include?(self.end_date.wday) #&&self.include_weekend!=1
      sum += self.weekend_leave_days
    end
    return sum
  end

  def weekend_leave_days
    sets = Attendance.special_attend_sets(self.start_date, self.end_date, self.employee_id)
    return case sets.size
             when 1
               set = sets.first
               sdate = [self.class.beginning_of_work_day(set.this_date), self.start_date].max
               edate = [self.class.end_of_work_day(set.this_date), self.end_date].min
               self.class.get_leave_time(sdate, edate)
             when 2
               set1, set2 = sets
               sdate1 = [self.class.beginning_of_work_day(set1.this_date), self.start_date].max
               edate1 = self.class.end_of_work_day(set1.this_date)
               _sum = self.class.get_leave_time(sdate1, edate1)

               sdate2 = self.class.beginning_of_work_day(set2.this_date)
               edate2 = [self.class.end_of_work_day(set2.this_date), self.end_date].min
               _sum += self.class.get_leave_time(sdate2, edate2)
               _sum
             else
               ; 0.0
           end
  end

  def cancel_apply
    reset_apply
    employee = self.employee; o_emp = Hr.user
    self.update_attribute('status', 6)
    if self.apply_cancel
      subject = "#{o_emp.username}取消了#{employee.username}提交的申请！"
      body = %{#{subject}<br><a href='/attendance/apply_leave_show?id=#{self.id}'>点击这里查看详细信息</a>}
      EmpMsg.send_msg(self.apply_to, [employee.id, self.apply_to_hr].compact, subject, body)
    else
      subject = "#{employee.username}取消了申请"
      body = %{#{subject}<br><a href='/attendance/apply_leave_show?id=#{self.id}'>点击这里查看详细信息</a>}
      EmpMsg.send_msg(employee.id, [self.apply_to, self.apply_to_hr].compact, subject, body)
    end
  end

  def send_message_for_apply_back
    employee = self.employee
    subject = "#{employee.username}希望退回已提交的申请，需要您审批"
    body = %{#{subject}<br><a href='/attendance/apply_leave_show?id=#{self.id}'>点击这里查看详细信息</a>}
    EmpMsg.send_msg(self.employee_id, self.apply_to||self.apply_to_hr, subject, body)
  end

  def reset_apply
    return unless self.was_approved?
    y_day = (Time.now - 1.day).end_of_day
    self.end_date||=self.start_date


    if self.end_date <= y_day
      Attendance.rebuild_attendances(self.employee_id, self.start_date, self.end_date)
    elsif self.start_date > y_day
    else
      Attendance.rebuild_attendances(self.employee_id, self.start_date, y_day)
    end
  end


end
