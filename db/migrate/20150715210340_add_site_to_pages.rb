class AddSiteToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :site, :string, default: 'localhost'  
  end
end
