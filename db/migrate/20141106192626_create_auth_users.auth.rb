# This migration comes from auth (originally 20141007223736)
class CreateAuthUsers < ActiveRecord::Migration
  def change
    create_table :auth_users do |t|
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :token, default: nil
      t.string :role, default: 'user'
      t.string :active, default: 'unconfirmed'

      t.timestamps
    end
  end
end
