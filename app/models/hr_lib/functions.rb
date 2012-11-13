#encoding:utf-8
#
# functions.rb
# 
# Created on 2007-9-2, 16:03:50
# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'date'

module HrLib
  module Functions
    
    module ClassMethods
      def date_field_extend(*fields)
        fields.each{|obj|
          module_eval %{     
              def #{obj.to_s}_text
                 self.#{obj.to_s}.strftime("%Y-%m-%d") if self.#{obj.to_s}
              end     
          }   
        }
      end
      
      def yes_no_field_extend(*fields)
        fields.each{|obj|
          module_eval %{     
              def #{obj.to_s}_text
                 (self.#{obj.to_s}&&self.#{obj.to_s}==1 ? "Yes" : "No")
              end     
          }   
        }
      end
    end
    
    def self.included(receiver)
      receiver.extend(ClassMethods)
    end
    
    def get_array_type_text(array, value)
      array.inject(nil){|r, t| r || (t[0] if t[1] == value)}
    end
    alias_method :get_array_type_label, :get_array_type_text
    
    def not_empty(value)
      if value
        if value.class==String
          return value.strip.size>0
        else
          return value.size>0
        end
      end
      false
    end

    def not_all_empty(values)
      for v in values
        return true if not_empty(v)
      end
      return false
    end
    
    def encode_char(char, salt, seperator = 1.chr)
      result = []
      char.reverse.each_byte{|b| result << (b + salt[1,1].to_i)}
      result.join(seperator)
    end
    
    def decode_char(char, salt, seperator = 1.chr)
      char.split(seperator).map{|c| (c.to_i - salt[1,1].to_i).chr}.join.reverse
    end
    
    def date_valid?(date_str)
      begin
        Date.parse(date_str)
      rescue
        return nil
      end
    end

    def check_email_group_string(emails_string)
      #check email
      unless emails_string.blank?
        emails = emails_string.gsub("\n", "").split(";").map{|e| e.strip}
        emails.each{|e| raise "Email格式错误，请输入正确的Email地址，如果有多个Email地址请使用分号分割！" unless email_format_check(e)}
      end
    end

    def email_format_check(email)
      email =~ %r{^([0-9a-zA-Z_]([-.\w]*[0-9a-zA-Z_])*@(([0-9a-zA-Z])+([-\w]*[0-9a-zA-Z])*\.)+[a-zA-Z]{2,9})$}i
    end
  end
  
end
  