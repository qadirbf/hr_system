class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.string "session_id", :default => "", :null => false
      t.string "username", :limit => 45, :default => "", :null => false
      t.integer "user_id", :precision => 38, :scale => 0, :null => false
      t.integer "last", :precision => 38, :scale => 0, :default => 0, :null => false
      t.string "ip", :limit => 20
      t.timestamps
    end

    add_index "user_sessions", ["session_id"], :name => "user_session_sid"
    add_index "user_sessions", ["user_id", "last"], :name => "user_session_user_id"
    add_index "user_sessions", ["username"], :name => "user_session_username"

  end
end
