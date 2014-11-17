class AddAlternateEmailToUser < ActiveRecord::Migration
  def change
    add_column :auth_users, :alternate_email, :string
  end
end
