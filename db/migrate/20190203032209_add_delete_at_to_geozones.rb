class AddDeleteAtToGeozones < ActiveRecord::Migration
  def change
    add_column :geozones, :deleted_at, :datetime
    add_index :geozones, :deleted_at
  end
end
