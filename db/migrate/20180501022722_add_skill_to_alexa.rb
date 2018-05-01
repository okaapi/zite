class AddSkillToAlexa < ActiveRecord::Migration[5.0]
  def change
    add_column :alexas, :skill, :string
  end
end
