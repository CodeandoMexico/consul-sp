class Budget::Investment::Exporter
  require 'csv'

  def initialize(investments)
    @investments = investments
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @investments.each { |investment| csv << csv_values(investment) }
    end
  end

  private

  def headers
    [
      I18n.t("admin.budget_investments.index.list.id"),
      I18n.t("admin.budget_investments.index.list.title"),
      I18n.t("admin.budget_investments.index.list.supports"),
      I18n.t("admin.budget_investments.index.list.admin"),
      I18n.t("admin.budget_investments.index.list.valuator"),
      I18n.t("admin.budget_investments.index.list.valuation_group"),
      I18n.t("admin.budget_investments.index.list.geozone"),
      I18n.t("admin.budget_investments.index.list.feasibility"),
      I18n.t("admin.budget_investments.index.list.valuation_finished"),
      I18n.t("admin.budget_investments.index.list.selected"),
      I18n.t("admin.budget_investments.index.list.visible_to_valuators"),
      I18n.t("admin.budget_investments.index.list.author_username"),
      'Sector',
      'Documento 1',
      'Documento 2',
      'Documento 3',
      I18n.t("admin.budget_investments.index.list.content"),
      I18n.t("admin.budget_investments.index.list.creation"),
      I18n.t("admin.budget_investments.index.list.updated")
    ]
  end

  def csv_values(investment)
    [
      investment.id.to_s,
      investment.title,
      investment.total_votes.to_s,
      admin(investment),
      investment.assigned_valuators || '-',
      investment.assigned_valuation_groups || '-',
      investment.heading.name,
      price(investment),
      investment.valuation_finished? ? I18n.t('shared.yes') : I18n.t('shared.no'),
      investment.selected? ? I18n.t('shared.yes') : I18n.t('shared.no'),
      investment.visible_to_valuators? ? I18n.t('shared.yes') : I18n.t('shared.no'),
      investment.author.username,
      investment.author.sector,
      get_documents_url(investment.documents.first),
      get_documents_url(investment.documents.second),
      get_documents_url(investment.documents.third),
      ActionView::Base.full_sanitizer.sanitize(investment.description),
      investment.created_at.strftime("%d/%m/%Y"),
      investment.updated_at.strftime("%d/%m/%Y")
    ]
  end

  def admin(investment)
    if investment.administrator.present?
      investment.administrator.name
    else
      I18n.t("admin.budget_investments.index.no_admin_assigned")
    end
  end

  def get_documents_url(investment)
    return "" if investment.nil?
    url = investment.attachment.url
    "https#{url}"
  end

  def price(investment)
    price_string = "admin.budget_investments.index.feasibility.#{investment.feasibility}"
    I18n.t(price_string, price: investment.formatted_price)
  end
end
