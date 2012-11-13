# 
# security.rb
# 
# Created on 2007-10-7, 16:38:06
require 'digest/sha1'

module HrLib
  module Security
    include Functions

    LOGIN_REGEX  = /\A\w[\w\.\-_@]+\z/

    module ClassMethods
      def authenticate(name, password)
        user = self.find_by_username(name)
        if user
          expected_password = self.new.encrypted_password(password, user.salt)
          if user.hashed_password != expected_password
            user = nil
          end
        end
        user
      end
      
      def generate_random_password
        char_list = ("A".."Z").to_a + (2..9).to_a + ("a".."z").to_a
        return (1..6).inject(""){|p, i| p + char_list[rand(char_list.size)].to_s}
      end
    end

    def self.included(receiver)
      receiver.extend(ClassMethods)
    end
    
    attr_accessor :password
    
    def password
      @password
    end

    def password=(pwd)
      @password = pwd
      create_new_salt
      self.hashed_password = encrypted_password(self.password, self.salt)
      self.encode = encode_char(self.password, self.salt)
    end
    
    def decode_pass
      unless self.encode.blank?
        decode_char self.encode, self.salt
      else
        nil
      end
    end
    
    def create_new_salt
      self.salt = self.object_id.to_s + rand.to_s
    end
    
    def encrypted_password(password, salt)
      string_to_hash = password + "hr_sys" + salt # 'hr_sys' makes it harder to guess
      Digest::SHA1.hexdigest(string_to_hash)
    end
  end
end
