class User < ActiveRecord::Base
  extend Enumerize

  include Verification

  devise :database_authenticatable, :registerable, :confirmable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, :async, :password_expirable, :secure_validatable,
         authentication_keys: [:login]

  enumerize :sector, in: { K1: 1,
                           K2: 2,
                           K3: 3,
                           K4: 4,
                           K5: 5,
                           K6: 6,
                           MANUAL: 7 }, scope: true

  acts_as_voter
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  include Graphqlable

  has_one :administrator
  has_one :moderator
  has_one :valuator
  has_one :manager
  has_one :poll_officer, class_name: "Poll::Officer"
  has_one :organization
  has_one :lock
  has_one :survey
  has_one :address_user
  has_many :flags
  has_many :likes
  has_many :identities, dependent: :destroy
  has_many :debates, -> { with_hidden }, foreign_key: :author_id
  has_many :proposals, -> { with_hidden }, foreign_key: :author_id
  has_many :budget_investments, -> { with_hidden }, foreign_key: :author_id, class_name: 'Budget::Investment'
  has_many :comments, -> { with_hidden }
  has_many :spending_proposals, foreign_key: :author_id
  has_many :failed_census_calls
  has_many :notifications
  has_many :direct_messages_sent,     class_name: 'DirectMessage', foreign_key: :sender_id
  has_many :direct_messages_received, class_name: 'DirectMessage', foreign_key: :receiver_id
  has_many :legislation_answers, class_name: 'Legislation::Answer', dependent: :destroy, inverse_of: :user
  has_many :follows
  has_and_belongs_to_many :colonium
  belongs_to :geozone
  has_attached_file :ife, styles: { medium: "300x300>" }, default_url: "/images/:style/missing.png"
  do_not_validate_attachment_file_type :ife


  validates :username, presence: true, if: :username_required?
  validates :username, uniqueness: { scope: :registering_with_oauth }, if: :username_required?
  validates :document_number, uniqueness: false, allow_nil: true

  validate :validate_username_length

  validates :official_level, inclusion: {in: 0..5}
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  validates_associated :organization, message: false

  accepts_nested_attributes_for :organization, update_only: true

  attr_accessor :skip_password_validation
  attr_accessor :use_redeemable_code
  attr_accessor :login

  scope :administrators, -> { joins(:administrator) }
  scope :moderators,     -> { joins(:moderator) }
  scope :organizations,  -> { joins(:organization) }
  scope :officials,      -> { where("official_level > 0") }
  scope :newsletter,     -> { where(newsletter: true) }
  scope :for_render,     -> { includes(:organization) }
  scope :by_document,    ->(document_type, document_number) do
    where(document_type: document_type, document_number: document_number)
  end
  scope :email_digest,   -> { where(email_digest: true) }
  scope :active,         -> { where(erased_at: nil) }
  scope :erased,         -> { where.not(erased_at: nil) }
  scope :public_for_api, -> { all }
  scope :by_comments,    ->(query, topics_ids) { joins(:comments).where(query, topics_ids).uniq }
  scope :by_authors,     ->(author_ids) { where("users.id IN (?)", author_ids) }
  scope :by_username_email_or_document_number, ->(search_string) do
    string = "%#{search_string}%"
    where("username ILIKE ? OR email ILIKE ? OR document_number ILIKE ?", string, string, string)
  end

  before_validation :clean_document_number

  # Get the existing user by email if the provider gives us a verified email.
  def self.first_or_initialize_for_oauth(auth)
    oauth_email           = auth.info.email
    oauth_email_confirmed = oauth_email.present? && (auth.info.verified || auth.info.verified_email)
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed

    oauth_user || User.new(
      username:  auth.info.name || auth.uid,
      email: oauth_email,
      oauth_email: oauth_email,
      password: Devise.friendly_token[0, 20],
      terms_of_service: '1',
      confirmed_at: oauth_email_confirmed ? DateTime.current : nil
    )
  end

  def name
    organization? ? organization.name : username
  end

  def likes?(investment)
    investment.likes.where(user_id: id).any?
  end

  def debate_votes(debates)
    voted = votes.for_debates(Array(debates).map(&:id))
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def proposal_votes(proposals)
    voted = votes.for_proposals(Array(proposals).map(&:id))
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def legislation_proposal_votes(proposals)
    voted = votes.for_legislation_proposals(proposals)
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def spending_proposal_votes(spending_proposals)
    voted = votes.for_spending_proposals(spending_proposals)
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def budget_investment_votes(budget_investments)
    voted = votes.for_budget_investments(budget_investments)
    voted.each_with_object({}) { |v, h| h[v.votable_id] = v.value }
  end

  def comment_flags(comments)
    comment_flags = flags.for_comments(comments)
    comment_flags.each_with_object({}){ |f, h| h[f.flaggable_id] = true }
  end

  def voted_in_group?(group)
    votes.for_budget_investments(Budget::Investment.where(group: group)).exists?
  end

  def administrator?
    administrator.present?
  end

  def moderator?
    moderator.present?
  end

  def valuator?
    valuator.present?
  end

  def manager?
    manager.present?
  end

  def poll_officer?
    poll_officer.present?
  end

  def organization?
    organization.present?
  end

  def verified_organization?
    organization && organization.verified?
  end

  def official?
    official_level && official_level > 0
  end

  def add_official_position!(position, level)
    return if position.blank? || level.blank?
    update official_position: position, official_level: level.to_i
  end

  def remove_official_position!
    update official_position: nil, official_level: 0
  end

  def has_official_email?
    domain = Setting['email_domain_for_officials']
    email.present? && ((email.end_with? "@#{domain}") || (email.end_with? ".#{domain}"))
  end

  def display_official_position_badge?
    return true if official_level > 1
    official_position_badge? && official_level == 1
  end

  def block
    debates_ids = Debate.where(author_id: id).pluck(:id)
    comments_ids = Comment.where(user_id: id).pluck(:id)
    proposal_ids = Proposal.where(author_id: id).pluck(:id)
    investment_ids = Budget::Investment.where(author_id: id).pluck(:id)
    proposal_notification_ids = ProposalNotification.where(author_id: id).pluck(:id)

    hide

    Debate.hide_all debates_ids
    Comment.hide_all comments_ids
    Proposal.hide_all proposal_ids
    Budget::Investment.hide_all investment_ids
    ProposalNotification.hide_all proposal_notification_ids
  end

  def erase(erase_reason = nil)
    update(
      erased_at: Time.current,
      erase_reason: erase_reason,
      username: nil,
      email: nil,
      unconfirmed_email: nil,
      phone_number: nil,
      encrypted_password: "",
      confirmation_token: nil,
      reset_password_token: nil,
      email_verification_token: nil,
      confirmed_phone: nil,
      unconfirmed_phone: nil
    )
    identities.destroy_all
  end

  def erased?
    erased_at.present?
  end

  def self.to_csv

    attributes = %w{id
                    name
                    email
                    junta_vecinal
                    sector
                    document_number
                    created_at
                    user_type
                    roles_category
                    latitud
                    longitud
                    calle
                    numero
                    colonia
                    date_of_birth
                    genero
                    nivel_estudios
                    ocupacion
                    ingreso_mensual
                    voto_ultimas_elecciones
                    voluntario_doce_meses
                    evento_doce_meses
                    ultimo_proceso_legislativo
                    como_descubrio
                    promocion_espacion_publicos
                    otro_medio}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.find_each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def latitud
    return "" if !level_three_verified?
    Catastral.where(exped: document_number).first.latitude
  end

  def longitud
    return "" if !level_three_verified?
    Catastral.where(exped: document_number).first.longitude
  end

  def calle
    return "" if !level_three_verified?
    Catastral.where(exped: document_number).first.ubic
  end

  def numero
    return "" if !level_three_verified?
    Catastral.where(exped: document_number).first.numextubi
  end

  def colonia
    return "" if !level_three_verified?
    Catastral.where(exped: document_number).first.colubi
  end

  def roles_category
    roles = []
    roles << :admin if self.administrator?
    roles << :moderator if self.moderator?
    roles << :valuator if self.valuator?
    roles << :manager if self.manager?
    roles << :poll_officer if self.poll_officer?
    roles << :official if self.official?
    roles << :organization if self.organization?
    roles
  end

  def genero
    if self.survey.present?
      self.survey.genre
    else
      "N/A"
    end
  end

  def ultimo_proceso_legislativo
    if self.survey.present?
      self.survey.participate_last_year
    else
      "N/A"
    end
  end

  def como_descubrio
    if self.survey.present?
      self.survey.how_discover
    else
      "N/A"
    end
  end

  def otro_medio
    if self.survey.present?
      self.survey.other_text
    else
      "N/A"
    end
  end

  def promocion_espacion_publicos
    if self.survey.present?
      self.survey.promotion_text
    else
      "N/A"
    end
  end

  def ocupacion
    if self.survey.present?
      self.survey.job
    else
      "N/A"
    end
  end

  def ingreso_mensual
    if self.survey.present?
      self.survey.salary
    else
      "N/A"
    end
  end

  def voto_ultimas_elecciones
    if self.survey.present?
      self.survey.recently_vote
    else
      "N/A"
    end
  end

  def voluntario_doce_meses
    if self.survey.present?
      self.survey.social_work
    else
      "N/A"
    end
  end

  def evento_doce_meses
    if self.survey.present?
      self.survey.attend_event
    else
      "N/A"
    end
  end

  def nivel_estudios
    if self.survey.present?
      self.survey.school_grade
    else
      "N/A"
    end
  end

  def junta_vecinal
    return "" if !level_three_verified?
    colonium.first.junta_nom
  end

  def take_votes_if_erased_document(document_number, document_type)
    erased_user = User.erased.where(document_number: document_number)
                             .where(document_type: document_type).first
    if erased_user.present?
      take_votes_from(erased_user)
      erased_user.update(document_number: nil, document_type: nil)
    end
  end

  def take_votes_from(other_user)
    return if other_user.blank?
    Poll::Voter.where(user_id: other_user.id).update_all(user_id: id)
    Budget::Ballot.where(user_id: other_user.id).update_all(user_id: id)
    Vote.where("voter_id = ? AND voter_type = ?", other_user.id, "User").update_all(voter_id: id)
    data_log = "id: #{other_user.id} - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
    update(former_users_data_log: "#{former_users_data_log} | #{data_log}")
  end

  def locked?
    Lock.find_or_create_by(user: self).locked?
  end

  def self.search(term)
    term.present? ? where("email = ? OR username ILIKE ?", term, "%#{term}%") : none
  end

  def self.username_max_length
    @@username_max_length ||= columns.find { |c| c.name == 'username' }.limit || 60
  end

  def self.minimum_required_age
    (Setting['min_age_to_participate'] || 16).to_i
  end

  def show_welcome_screen?
    verification = Setting["feature.user.skip_verification"].present? ? true : unverified?
    sign_in_count == 1 && verification && !organization && !administrator?
  end

  def password_required?
    return false if skip_password_validation
    super
  end

  def username_required?
    !organization? && !erased?
  end

  def email_required?
    !erased? && unverified?
  end

  def locale
    self[:locale] ||= I18n.default_locale.to_s
  end

  def confirmation_required?
    super && !registering_with_oauth
  end

  def send_oauth_confirmation_instructions
    if oauth_email != email
      update(confirmed_at: nil)
      send_confirmation_instructions
    end
    update(oauth_email: nil) if oauth_email.present?
  end

  def name_and_email
    "#{name} (#{email})"
  end

  def age
    Age.in_years(date_of_birth)
  end

  def save_requiring_finish_signup
    begin
      self.registering_with_oauth = true
      save(validate: false)
    # Devise puts unique constraints for the email the db, so we must detect & handle that
    rescue ActiveRecord::RecordNotUnique
      self.email = nil
      save(validate: false)
    end
    true
  end

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def public_proposals
    public_activity? ? proposals : User.none
  end

  def public_debates
    public_activity? ? debates : User.none
  end

  def public_comments
    public_activity? ? comments : User.none
  end

  # overwritting of Devise method to allow login using email OR username
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions.to_hash).where(["lower(email) = ?", login.downcase]).first ||
    where(conditions.to_hash).where(["username = ?", login]).first
  end

  def self.find_by_manager_login(manager_login)
    find_by(id: manager_login.split("_").last)
  end

  def interests
    followables = follows.map(&:followable)
    followables.compact.map { |followable| followable.tags.map(&:name) }.flatten.compact.uniq
  end

  private

    def clean_document_number
      return unless document_number.present?
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase
    end

    def validate_username_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :username,
        maximum: User.username_max_length)
      validator.validate(self)
    end

end
