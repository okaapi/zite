class AddRememberDigestToUserSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sessions, :remember_digest, :string
  end
end
