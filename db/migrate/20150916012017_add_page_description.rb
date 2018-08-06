class AddPageDescription < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :meta_desc, :string, default: nil 
  end
end
