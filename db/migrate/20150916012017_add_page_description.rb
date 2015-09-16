class AddPageDescription < ActiveRecord::Migration
  def change
    add_column :pages, :desc, :string, default: 'no description' 
  end
end
