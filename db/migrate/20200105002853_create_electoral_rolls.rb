class CreateElectoralRolls < ActiveRecord::Migration
  def change
    create_table :electoral_rolls do |t|
      t.string :entity
      t.integer :constituency_id
      t.integer :municipality_id
      t.integer :electoral_section_id
      t.integer :locality_id
      t.integer :block_id
      t.integer :ocr_number
      t.integer :cic_number
      t.integer :credential_issuance_number
      t.string :municipality_name
      t.string :sex
      t.integer :year_of_registry
      t.string :paternal_last_name_initial
      t.string :maternal_last_name_initial
      t.string :name_initial
    end
  end
end
