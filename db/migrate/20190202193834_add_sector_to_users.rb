class AddSectorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sector, :string
  end
end
