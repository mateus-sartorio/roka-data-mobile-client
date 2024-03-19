class CreateReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :receipts do |t|
      t.date :handout_date
      t.decimal :value
      t.references :resident, null: false, foreign_key: true
      t.references :currency_handout, null: false, foreign_key: true

      t.timestamps
    end
  end
end
