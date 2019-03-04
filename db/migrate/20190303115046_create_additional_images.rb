class CreateAdditionalImages < ActiveRecord::Migration
  def change
    create_table :additional_images do |t|
      t.attachment :photo
      t.integer :investment_id

      t.timestamps null: false
    end
    add_index :additional_images, :investment_id
  end
end
