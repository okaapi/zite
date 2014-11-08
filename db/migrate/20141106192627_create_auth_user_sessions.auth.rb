# This migration comes from auth (originally 20141008203151)
class CreateAuthUserSessions < ActiveRecord::Migration
  def change
    create_table :auth_user_sessions do |t|
      t.belongs_to :user, index: true
      t.string :client
      t.string :ip
      t.timestamps
    end
  end
end
