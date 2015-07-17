class AddSiteToUserActions < ActiveRecord::Migration
  def change
    add_column :user_actions, :site, :string, default: 'localhost'  
  end
end
