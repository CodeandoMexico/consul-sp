class Geozone < ActiveRecord::Base
  acts_as_paranoid
  include Graphqlable

  has_many :proposals, dependent: :destroy
  has_many :spending_proposals, dependent: :destroy
  has_many :debates, dependent: :destroy
  has_many :users, dependent: :destroy
  validates :name, presence: true

  scope :public_for_api, -> { all }

  def self.names
    Geozone.pluck(:name)
  end

  def self.city
    where(name: 'city').first
  end

  def safe_to_destroy?
    Geozone.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(geozone: self).empty?
    end
  end
end
