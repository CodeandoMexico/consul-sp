class Verification::Residence
  include ActiveModel::Model
  include ActiveModel::Dates
  include ActiveModel::Validations::Callbacks

  attr_accessor :user, :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service

  before_validation :retrieve_census_data

  validates :document_number, presence: true
  #validates :document_type, presence: true
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
  validates :terms_of_service, acceptance: { allow_nil: false }
  validates :postal_code, length: { is: 5 }

  validate :allowed_age
  validate :document_number_uniqueness
  validate  :exped_exist
  validate  :ife_exist

  def initialize(attrs = {})
    self.date_of_birth = parse_date('date_of_birth', attrs)
    attrs = remove_date('date_of_birth', attrs)
    super
    clean_document_number
  end

  def save

    return false unless valid?

    user.take_votes_if_erased_document(document_number, document_type)

    user.update(document_number:       document_number,
                document_type:         '1', #document_type
                geozone:               geozone,
                date_of_birth:         date_of_birth.in_time_zone.to_datetime,
                sector:                district_code,
                residence_verified_at: Time.current)
  end

  def allowed_age
    return if errors[:date_of_birth].any? || Age.in_years(date_of_birth) >= User.minimum_required_age
    errors.add(:date_of_birth, I18n.t('verification.residence.new.error_not_allowed_age'))
  end

  def document_number_uniqueness
    if(User.active.where(document_number: document_number).count >= 4)
      errors.add(:document_number, "No pueden existir mas de 4 registros con este numero")
    else
      return true
    end
  end

  def store_failed_attempt
    FailedCensusCall.create(
      user: user,
      document_number: document_number,
      document_type: document_type,
      date_of_birth: date_of_birth,
      postal_code: postal_code
    )
  end

  def geozone
    Geozone.where(census_code: district_code).first
  end

  def district_code
    @census_data.electoral_section_id
  end

  def exped_exist
    self.errors.add(:document_number, "Este Numero No Existe") unless @census_data.present?
  end

  def ife_exist
    #self.user.ife.present?
    if self.user.ife.url.include? "missing"
      self.errors.add(:base, "Tienes que subir tu INE")
    end
  end
  private

    def retrieve_census_data
      @census_data = ElectoralRoll.find_by cic_number: document_number
    end

    def residency_valid?
      @census_data.present?
    end

    def clean_document_number
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
    end

end
