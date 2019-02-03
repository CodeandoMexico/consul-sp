class AddRegistersToCatastrals < ActiveRecord::Migration
  def change
    add_column :catastrals, :registers, :integer, default: 0
  end
end
