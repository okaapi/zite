class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name
      t.text :content
      t.integer :user_id
      t.string :visibility, default: 'any'
      t.string :editability, default: 'editor'
      t.string :menu, default: 'true'
      t.string :lock, default: 'false'
      t.string :editor, default: 'wysiwyg'

      t.timestamps null:false
    end
  end
end
