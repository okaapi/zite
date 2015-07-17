class AddSiteToPages < ActiveRecord::Migration
  def change
    add_column :pages, :site, :string, default: 'localhost'  
  end
end
