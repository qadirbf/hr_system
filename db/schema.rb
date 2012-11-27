# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121121091257) do

  create_table "candidates", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "employee_id"
    t.integer  "grab_by"
    t.datetime "grab_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "candidates", ["contact_id"], :name => "index_candidates_on_contact_id"
  add_index "candidates", ["created_at"], :name => "index_candidates_on_created_at"
  add_index "candidates", ["employee_id"], :name => "index_candidates_on_employee_id"
  add_index "candidates", ["grab_at"], :name => "index_candidates_on_grab_at"
  add_index "candidates", ["grab_by"], :name => "index_candidates_on_grab_by"
  add_index "candidates", ["updated_at"], :name => "index_candidates_on_updated_at"

  create_table "cities", :force => true do |t|
    t.string   "name_cn"
    t.string   "name"
    t.string   "city_postcode"
    t.string   "city_code"
    t.integer  "country_id"
    t.integer  "province_id"
    t.integer  "city_type",      :limit => 2
    t.integer  "parent_city_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "construction_areas", :force => true do |t|
    t.string "name"
  end

  create_table "contact_demands", :force => true do |t|
    t.integer  "firm_id"
    t.integer  "employee_id"
    t.integer  "firm_type_id"
    t.integer  "position_type_id"
    t.integer  "status_id",            :limit => 2
    t.integer  "salary_type_id",       :limit => 2
    t.string   "salary_value"
    t.string   "salary_notes",         :limit => 2000
    t.integer  "province_id"
    t.integer  "city_id"
    t.string   "work_place"
    t.integer  "contact_num",          :limit => 8
    t.string   "demand_notes",         :limit => 3000
    t.integer  "need_ad_recruit",      :limit => 2
    t.string   "ad_recruit_notes",     :limit => 3000
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "sales_notes",          :limit => 3000
    t.datetime "contract_start"
    t.datetime "contract_end"
    t.integer  "is_pay"
    t.integer  "order_income"
    t.string   "position_type_text"
    t.string   "position_description"
    t.string   "sales_notes",      :limit => 3000
    t.datetime "contract_start"
    t.datetime "contract_end"
    t.integer  "is_pay"
    t.integer  "order_income"
  end

  add_index "contact_demands", ["city_id"], :name => "idx_demand_city"
  add_index "contact_demands", ["employee_id"], :name => "idx_demand_emp"
  add_index "contact_demands", ["firm_id"], :name => "idx_demand_firm"
  add_index "contact_demands", ["firm_type_id"], :name => "idx_demand_firm_type"
  add_index "contact_demands", ["position_type_id"], :name => "idx_demand_pos_type"
  add_index "contact_demands", ["province_id"], :name => "idx_demand_province"

  create_table "contact_positions", :force => true do |t|
    t.string  "name"
    t.integer "firm_type_id"
  end

  add_index "contact_positions", ["firm_type_id"], :name => "idx_position_firm_type"

  create_table "contacts", :force => true do |t|
    t.integer  "firm_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "salutation"
    t.string   "position_cn"
    t.integer  "sex",                     :limit => 2
    t.integer  "age",                     :limit => 3
    t.datetime "birthday"
    t.integer  "work_year",               :limit => 3
    t.datetime "start_work_date"
    t.integer  "resigned",                :limit => 2
    t.integer  "want_new_job",            :limit => 2
    t.string   "phone"
    t.string   "phone_ext",               :limit => 100
    t.string   "mobile"
    t.string   "email"
    t.string   "fax"
    t.string   "postcode",                :limit => 30
    t.integer  "country_id"
    t.integer  "province_id"
    t.integer  "city_id"
    t.string   "address",                 :limit => 1000
    t.string   "address2",                :limit => 1000
    t.integer  "address_same_as_firm",    :limit => 2
    t.integer  "contact_no_same_as_firm", :limit => 2
    t.integer  "firm_type_id"
    t.integer  "position_type_id"
    t.integer  "expect_firm_type_id"
    t.integer  "expect_position_type_id"
    t.string   "expect_prof_notes",       :limit => 3000
    t.string   "expect_work_place",       :limit => 2000
    t.integer  "expect_salary",           :limit => 2
    t.string   "salary_notes",            :limit => 3000
    t.string   "notes",                   :limit => 3000
    t.integer  "status_id",               :limit => 2
    t.integer  "employee_id"
    t.string   "resume_file",             :limit => 500
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "position_type"
  end

  add_index "contacts", ["city_id"], :name => "idx_ctc_city"
  add_index "contacts", ["created_at"], :name => "idx_ctc_created_at"
  add_index "contacts", ["created_by"], :name => "idx_ctc_create_user"
  add_index "contacts", ["employee_id"], :name => "idx_ctc_emp"
  add_index "contacts", ["firm_id"], :name => "idx_ctc_firm"
  add_index "contacts", ["province_id"], :name => "idx_ctc_province"
  add_index "contacts", ["status_id"], :name => "idx_ctc_status"
  add_index "contacts", ["updated_at"], :name => "idx_ctc_updated_at"
  add_index "contacts", ["updated_by"], :name => "idx_ctc_update_user"

  create_table "countries", :force => true do |t|
    t.string   "name_cn"
    t.string   "name"
    t.string   "full_name"
    t.string   "full_name_en"
    t.string   "abbv"
    t.string   "currency_symbol"
    t.decimal  "exchange_rate",      :precision => 10, :scale => 0
    t.string   "access_code"
    t.string   "short_code"
    t.string   "continent_name"
    t.string   "continent_position"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  create_table "departments", :force => true do |t|
    t.string "name"
  end

  create_table "emp_msgs", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "to_names",   :limit => 1000
    t.string   "title",      :limit => 1000
    t.string   "content",    :limit => 3000
    t.integer  "viewed",     :limit => 2
    t.string   "url",        :limit => 1000
    t.datetime "created_at"
  end

  add_index "emp_msgs", ["from_id"], :name => "emp_msg_form_id"
  add_index "emp_msgs", ["to_id"], :name => "emp_msg_to_id"
  add_index "emp_msgs", ["viewed"], :name => "emp_msg_viewed"

  create_table "employees", :force => true do |t|
    t.string   "username",        :limit => 100
    t.string   "name_cn",         :limit => 100
    t.string   "hashed_password"
    t.string   "salt"
    t.integer  "active",          :limit => 2
    t.integer  "department_id"
    t.string   "email"
    t.string   "phone",           :limit => 50
    t.string   "phone_ext",       :limit => 50
    t.string   "mobile",          :limit => 50
    t.string   "fax",             :limit => 50
    t.string   "encode"
    t.datetime "join_date"
    t.datetime "leave_date"
    t.datetime "leave_reason"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "employees", ["active"], :name => "idx_emp_active"

  create_table "firm_cat_links", :force => true do |t|
    t.integer  "firm_id"
    t.integer  "firm_category_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "firm_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "firm_leads", :force => true do |t|
    t.integer  "firm_id"
    t.integer  "employee_id"
    t.integer  "leads_type_id"
    t.integer  "sales_stage_id", :limit => 2
    t.datetime "grab_date"
    t.datetime "expire_date"
    t.integer  "ext",            :limit => 3
    t.datetime "ext_at"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "firm_leads", ["employee_id"], :name => "idx_lead_emp"
  add_index "firm_leads", ["firm_id"], :name => "idx_lead_firm"
  add_index "firm_leads", ["leads_type_id"], :name => "idx_lead_type"

  create_table "firm_types", :force => true do |t|
    t.string "name"
  end

  create_table "firms", :force => true do |t|
    t.string   "firm_name"
    t.integer  "country_id"
    t.integer  "province_id"
    t.integer  "city_id"
    t.integer  "foreign_type_id", :limit => 2
    t.integer  "firm_type_id",    :limit => 2
    t.string   "address"
    t.string   "address2"
    t.string   "postcode",        :limit => 100
    t.string   "phone"
    t.string   "fax"
    t.string   "email",           :limit => 100
    t.string   "website"
    t.string   "notes",           :limit => 3000
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "rating"
    t.string   "product_notes",   :limit => 2000
  end

  add_index "firms", ["city_id"], :name => "idx_firm_city"
  add_index "firms", ["country_id"], :name => "idx_firm_country"
  add_index "firms", ["created_by"], :name => "idx_firm_cuser"
  add_index "firms", ["firm_type_id"], :name => "idx_firm_type"
  add_index "firms", ["foreign_type_id"], :name => "idx_firm_foreign"
  add_index "firms", ["province_id"], :name => "idx_firm_provn"
  add_index "firms", ["rating"], :name => "index_firms_on_rating"
  add_index "firms", ["updated_by"], :name => "idx_firm_uuser"

  create_table "leads_histories", :force => true do |t|
    t.integer  "firm_id"
    t.integer  "leads_type_id"
    t.integer  "old_emp_id"
    t.integer  "employee_id"
    t.datetime "grab_date"
    t.datetime "expire_date"
    t.integer  "ext",           :limit => 3
    t.integer  "created_by"
    t.datetime "created_at"
  end

  add_index "leads_histories", ["employee_id"], :name => "idx_lead_his_emp"
  add_index "leads_histories", ["firm_id"], :name => "idx_lead_his_firm"
  add_index "leads_histories", ["leads_type_id"], :name => "idx_lead_his_type"
  add_index "leads_histories", ["old_emp_id"], :name => "idx_lead_his_old_emp"

  create_table "login_histories", :force => true do |t|
    t.string   "username"
    t.integer  "employee_id"
    t.integer  "failed",      :limit => 2
    t.integer  "click_count"
    t.string   "ip",          :limit => 100
    t.string   "session_id",  :limit => 100
    t.string   "pwd",         :limit => 100
    t.datetime "created_at"
  end

  add_index "login_histories", ["created_at"], :name => "login_his_time"
  add_index "login_histories", ["failed"], :name => "login_his_failed"
  add_index "login_histories", ["username"], :name => "login_his_user"

  create_table "provinces", :force => true do |t|
    t.string   "name_cn"
    t.string   "name"
    t.integer  "region_id"
    t.integer  "country_id"
    t.string   "short_py",   :limit => 5
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "recalls", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "firm_id"
    t.integer  "contact_id"
    t.datetime "appt_date"
    t.integer  "contact_by_id", :limit => 2
    t.integer  "stage_id",      :limit => 2
    t.integer  "important",     :limit => 2
    t.string   "notes",         :limit => 3000
    t.datetime "completed_at"
    t.integer  "completed_by"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "recalls", ["appt_date"], :name => "idx_recall_appt_at"
  add_index "recalls", ["completed_at"], :name => "idx_recall_com_at"
  add_index "recalls", ["contact_id"], :name => "idx_recall_contact"
  add_index "recalls", ["employee_id"], :name => "idx_recall_emp"
  add_index "recalls", ["firm_id"], :name => "idx_recall_firm"

  create_table "recommend_histories", :force => true do |t|
    t.integer  "employee_id"
    t.integer  "contact_id"
    t.integer  "firm_id"
    t.integer  "contact_demand_id"
    t.integer  "status_id",         :limit => 2
    t.integer  "sales_id"
    t.string   "notes",             :limit => 3000
    t.datetime "interview_date"
    t.datetime "feedback_date"
    t.string   "feedback_notes",    :limit => 3000
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.datetime "contract_end_date"
  end

  add_index "recommend_histories", ["contact_demand_id"], :name => "idx_rec_his_demand"
  add_index "recommend_histories", ["contact_id"], :name => "idx_rec_his_contact"
  add_index "recommend_histories", ["employee_id"], :name => "idx_rec_his_emp"
  add_index "recommend_histories", ["firm_id"], :name => "idx_rec_his_firm"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "user_sessions", :force => true do |t|
    t.string   "session_id",               :default => "", :null => false
    t.string   "username",   :limit => 45, :default => "", :null => false
    t.integer  "user_id",                                  :null => false
    t.integer  "last",                     :default => 0,  :null => false
    t.string   "ip",         :limit => 20
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "user_sessions", ["session_id"], :name => "user_session_sid"
  add_index "user_sessions", ["user_id", "last"], :name => "user_session_user_id"
  add_index "user_sessions", ["username"], :name => "user_session_username"

end
