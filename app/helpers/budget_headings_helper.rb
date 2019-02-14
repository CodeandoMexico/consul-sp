module BudgetHeadingsHelper

  def budget_heading_select_options(budget)
    # TODO: filtro temporal
    if !current_user.colonium.nil?
      sectores_id = Budget::Group.where(name: "Sectores").first.id
      my_sector = budget.headings.where(group_id: sectores_id).where(slug: current_user.colonium.first.sector.downcase)
      colonias_id = Budget::Group.where(name: "Juntas Vecinales").first.id
      my_colonia = budget.headings.where(group_id: colonias_id).where(slug: current_user.colonium.first.junta_nom.parameterize)
      mi_desmadre = my_sector + my_colonia
      mi_desmadre.map do |heading|
        [heading.name_scoped_by_group, heading.id]
      end
  else
    budget.headings.order_by_group_name.map do |heading|
      [heading.name_scoped_by_group, heading.id]
    end
  end
end

  def heading_link(assigned_heading = nil, budget = nil)
    return nil unless assigned_heading && budget
    heading_path = budget_investments_path(budget, heading_id: assigned_heading.try(:id))
    link_to(assigned_heading.name, heading_path)
  end

end
