class CreateAlexas < ActiveRecord::Migration[5.0]
  def change
    create_table :alexas do |t|
      t.string :intent
      t.string :slot
      t.string :aux

      t.timestamps
    end
  end
end
