class Widget::Feed < ActiveRecord::Base
  self.table_name = "widget_feeds"

  KINDS = %w(proposals debates processes)

  def active?
    setting&.value&.present?
  end

  def setting
    Setting.where(key: "feature.homepage.widgets.feeds.#{kind}").first
  end

  def self.active
    KINDS.collect do |kind|
      feed = find_or_create_by(kind: kind)
      feed if feed.active?
    end.compact
  end

  def items
    send(kind)
  end

  def proposals
    Proposal.sort_by_hot_score.limit(limit)
  end

  def debates
    Debate.sort_by_hot_score.limit(limit)
  end

  def processes
    Legislation::Process.open.published.limit(limit)
  end
end
