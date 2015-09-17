class AddPageDescription < ActiveRecord::Migration
  def change
    add_column :pages, :meta_desc, :string, default: nil 
  end
end
