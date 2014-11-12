class AddParamsToUserAction < ActiveRecord::Migration
  def change
    add_column :auth_user_actions, :params, :string
  end
end
