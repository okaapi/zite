
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :alternate_email, default: ''
      t.string :password_digest
      t.string :token, default: nil
      t.string :role, default: 'user'
      t.string :active, default: 'unconfirmed'

      t.timestamps
    end
  end
end
