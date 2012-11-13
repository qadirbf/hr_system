#Encoding: utf-8
class UserSession < ActiveRecord::Base

  def self.clear_expired_sessions
    ActiveRecord::Base.connection.execute("delete from sessions where updated_at + INTERVAL #{$CLIENT_EXPIRE_MINUTES} MINUTE < now()")
    UserSession.delete_all("session_id not in (select session_id from sessions)")
  end

  def self.user_login_check(session_id, user, ip)
    UserSession.clear_expired_sessions

    #user_sessions = UserSession.where(["session_id = ?", session_id]).all

    UserSession.update_all("last = 0", ["username = ?", user.username.downcase])
    user_session = UserSession.new
    user_session.session_id = session_id
    user_session.username = user.username.downcase
    user_session.user_id = user.id
    user_session.ip = ip
    user_session.last = 1
    user_session.save!
    #ok
    return nil
  end

  def self.user_view_check(request)
    session_id = request.session_options[:id]
    ip = request.remote_ip()
    cookies = request.cookies

    user_session = UserSession.where(["session_id = ?", session_id]).first
    raise(AppError, "Session not exsit") if !user_session

    if user_session.last==0
      raise AppError, "重复登陆！"
    end

    if ip!=user_session.ip

    end
    return nil
  end

  def self.user_logout(session_id)
  end
end
