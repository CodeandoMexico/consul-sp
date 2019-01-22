class AddCoordinatesToCatastrals < ActiveRecord::Migration
  def change
    add_column :catastrals, :latitude, :float
    add_column :catastrals, :longitude, :float
  end
end
