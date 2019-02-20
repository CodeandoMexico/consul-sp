class AddSectorToBudgetHeading < ActiveRecord::Migration
  add_column :budget_headings, :sector, :text
end
