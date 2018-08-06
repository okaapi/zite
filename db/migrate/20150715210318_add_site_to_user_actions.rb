class AddSiteToUserActions < ActiveRecord::Migration[5.0]
  def change
    add_column :user_actions, :site, :string, default: 'localhost'  
  end
end
