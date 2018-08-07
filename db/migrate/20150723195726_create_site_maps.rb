class CreateSiteMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :site_maps do |t|
      t.string :external
      t.string :internal
      t.string :aux

      t.timestamps null:false
    end
  end
end
