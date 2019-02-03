class AddDistrictsToCatastrals < ActiveRecord::Migration
  def change
    add_column :catastrals, :district_code, :string
  end
end
