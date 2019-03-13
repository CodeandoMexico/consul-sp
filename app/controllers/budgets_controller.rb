class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  feature_flag :budgets

  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: :show

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, 'Not Found' unless budget_published?(@budget)
  end

  def index
    sector_names = {
      "K1": "K1 - Sector Obispo, Industrias y Río",
      "K2": "K2 - Sector Centro de San Pedro",
      "K3": "K3 - Sector Lomas",
      "K4": "K4 - Sector Valle",
      "K5": "K5 - Sector Montaña",
      "K6": "K6 - Sector Valle Oriente",
    }

    into_sector_name = proc { |key| sector_names[key.to_sym] }

    @finished_budgets = @budgets.finished.order(created_at: :desc)
    @budgets_coordinates = current_budget_map_locations
    @banners = Banner.in_section('budgets').with_active
    @sectores = Budget::Group.sectores
    @sectors_with_headings = Budget::Group.colonia
                                          .headings
                                          .group_by(&:sector)
                                          .transform_keys(&into_sector_name)
  end

end
