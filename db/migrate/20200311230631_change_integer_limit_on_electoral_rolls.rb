class ChangeIntegerLimitOnElectoralRolls < ActiveRecord::Migration
  def change
    change_column :electoral_rolls, :ocr_number, :integer, limit: 8
    change_column :electoral_rolls, :cic_number, :integer, limit: 8
  end
end
