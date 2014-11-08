# This migration comes from auth (originally 20141008210341)
class CreateAuthUserActions < ActiveRecord::Migration
  def change
    create_table :auth_user_actions do |t|
      t.belongs_to :user_session, index: true
      t.string :controller
      t.string :action

      t.timestamps
    end
  end
end
