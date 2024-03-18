class CreateCurrencyHandouts < ActiveRecord::Migration[7.0]
  def change
    create_table :currency_handouts do |t|
      t.string :title
      t.date :start_date
      t.decimal :value

      t.timestamps
    end
  end
end
