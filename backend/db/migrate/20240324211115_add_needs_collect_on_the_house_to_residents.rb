class AddNeedsCollectOnTheHouseToResidents < ActiveRecord::Migration[7.0]
  def change
    add_column :residents, :needs_collect_on_the_house, :boolean
  end
end
