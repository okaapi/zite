class CreateUserSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_sessions do |t|
      t.belongs_to :user, index: true
      t.string :client
      t.string :ip
      t.timestamps null:false
    end
  end
end
