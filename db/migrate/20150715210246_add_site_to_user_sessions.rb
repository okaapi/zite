class AddSiteToUserSessions < ActiveRecord::Migration[5.0]
  def change
    add_column :user_sessions, :site, :string, default: 'localhost'  
  end
end
