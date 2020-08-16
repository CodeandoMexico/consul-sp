class AddCoordinatesToElectoralRolls < ActiveRecord::Migration
  def change
    add_column :electoral_rolls, :latitude, :float
    add_column :electoral_rolls, :longitude, :float
  end
end
