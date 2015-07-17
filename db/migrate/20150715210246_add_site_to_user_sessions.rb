class AddSiteToUserSessions < ActiveRecord::Migration
  def change
    add_column :user_sessions, :site, :string, default: 'localhost'  
  end
end
