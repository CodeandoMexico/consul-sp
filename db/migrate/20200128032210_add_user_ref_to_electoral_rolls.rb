class AddUserRefToElectoralRolls < ActiveRecord::Migration
  def change
    add_reference :electoral_rolls, :user, index: true, foreign_key: true
  end
end
