class Catastral < ActiveRecord::Migration
  def change
    create_table :catastrals do |t|
      t.integer :exped
      t.text :ubic
      t.string :numextubi
      t.string :numintubi
      t.string :colubi
      t.timestamps
    end
  end
end
