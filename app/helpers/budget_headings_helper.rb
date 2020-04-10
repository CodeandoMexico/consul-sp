module BudgetHeadingsHelper

  def budget_heading_select_options_all(budget)
   budget.headings.order_by_group_name.map do |heading|
     [heading.name_scoped_by_group, heading.id]
   end
  end

  def get_coloniums
    Colonium.order('junta_nom ASC').map do |colonia|
      ["#{colonia.sector}: #{colonia.junta_nom}", colonia.id]
    end
  end

  def budget_heading_select_options(budget)
    if current_user.colonium
      sectores = Budget::Group.find_by(name: "Sectores")
      colonias = Budget::Group.find_by(name: "Juntas Vecinales")

      headings = [sectores, colonias].map do |group|
        group&.headings.find_by(slug: current_user.junta_vecinal.parameterize).presence ||
          group&.headings.find_by(slug: current_user.sector.parameterize)
      end

      headings.map { |heading|  [heading.name, heading.id] }
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
