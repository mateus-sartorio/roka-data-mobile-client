class CreateCollects < ActiveRecord::Migration[7.0]
  def change
    create_table :collects do |t|
      t.date :collected_on
      t.decimal :ammount
      t.references :resident, null: false, foreign_key: true

      t.timestamps
    end
  end
end
