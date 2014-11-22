# This migration comes from auth (originally 20141008210341)
class CreateUserActions < ActiveRecord::Migration
  def change
    create_table :user_actions do |t|
      t.belongs_to :user_session, index: true
      t.string :controller
      t.string :action
      t.string :params
      t.timestamps
    end
  end
end
