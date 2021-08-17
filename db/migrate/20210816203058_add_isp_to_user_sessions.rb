class AddIspToUserSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :user_sessions, :isp, :string
  end
end
