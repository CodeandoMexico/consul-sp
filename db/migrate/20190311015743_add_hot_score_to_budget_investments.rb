class AddHotScoreToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :hot_score, :bigint, default: 0
  end
end
