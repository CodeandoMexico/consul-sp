class CreateJoinTableCategoryProduct < ActiveRecord::Migration
  def change
    create_join_table :users, :colonia do |t|
      t.index [:user_id, :colonium_id]
      # t.index [:colonium_id, :user_id]
    end
  end
end
