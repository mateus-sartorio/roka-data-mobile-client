class CreateResidents < ActiveRecord::Migration[7.0]
  def change
    create_table :residents do |t|
      t.string :name
      t.integer :situation
      t.integer :roka_id
      t.boolean :has_plaque
      t.integer :registration_year
      t.string :address
      t.string :reference_point
      t.boolean :lives_in_JN
      t.string :phone
      t.boolean :is_on_whatsapp_group
      t.date :birthdate
      t.string :profession
      t.integer :residents_in_the_house
      t.string :observations

      t.timestamps
    end
  end
end
