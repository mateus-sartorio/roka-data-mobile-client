class AddUniqueIndexToRokaId < ActiveRecord::Migration[7.0]
  def change
    add_index :residents, :roka_id, unique: true
  end
end
