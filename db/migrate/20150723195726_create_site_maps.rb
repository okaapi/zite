class CreateSiteMaps < ActiveRecord::Migration
  def change
    create_table :site_maps do |t|
      t.string :external
      t.string :internal
      t.string :aux

      t.timestamps
    end
  end
end
