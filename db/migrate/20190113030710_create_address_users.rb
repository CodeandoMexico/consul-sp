class CreateAddressUsers < ActiveRecord::Migration
  def change
    create_table :address_users do |t|
      t.references :user, index: true, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.text :full_address
      t.integer :zoom

      t.timestamps null: false
    end
  end
end
