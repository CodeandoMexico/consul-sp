class Image < ActiveRecord::Base
  include ImagesHelper
  include ImageablesHelper

  TITLE_LENGTH_RANGE = 4..80
  MIN_SIZE = 475
  MAX_IMAGE_SIZE = 1.megabyte
  ACCEPTED_CONTENT_TYPE = %w(image/jpeg image/jpg).freeze

  has_attached_file :attachment, styles: { large: "x#{MIN_SIZE}", medium: "300x300#", thumb: "140x245#" },
                                 url: "/system/:class/:prefix/:style/:hash.:extension",
                                 hash_data: ":class/:style",
                                 use_timestamp: false,
                                 hash_secret: Rails.application.secrets.secret_key_base
  attr_accessor :cached_attachment

  belongs_to :user
  belongs_to :imageable, polymorphic: true

  # Disable paperclip security validation due to polymorphic configuration
  # Paperclip do not allow to use Procs on valiations definition
  do_not_validate_attachment_file_type :attachment
  validate :attachment_presence
  validate :validate_attachment_content_type,         if: -> { attachment.present? }
  validate :validate_attachment_size,                 if: -> { attachment.present? }
  validates :title, presence: true, length: { in: TITLE_LENGTH_RANGE }
  validates :user_id, presence: true
  validates :imageable_id, presence: true,         if: -> { persisted? }
  validates :imageable_type, presence: true,       if: -> { persisted? }
  validate :validate_image_dimensions, if: -> { attachment.present? && attachment.dirty? }

  before_save :set_attachment_from_cached_attachment, if: -> { cached_attachment.present? }
  after_save :remove_cached_attachment,               if: -> { cached_attachment.present? }

  def set_cached_attachment_from_attachment
    self.cached_attachment = if Paperclip::Attachment.default_options[:storage] == :filesystem
                               attachment.path
                             else
                               attachment.url
                             end
  end

  def set_attachment_from_cached_attachment
    self.attachment = if Paperclip::Attachment.default_options[:storage] == :filesystem
                        File.open(cached_attachment)
                      else
                        open("https:#{cached_attachment}")
                      end
  end

  Paperclip.interpolates :prefix do |attachment, style|
    attachment.instance.prefix(attachment, style)
  end

  def prefix(attachment, _style)
    if !attachment.instance.persisted?
      "cached_attachments/user/#{attachment.instance.user_id}"
    else
      ":attachment/:id_partition"
    end
  end

  private

    def imageable_class
      imageable_type.constantize if imageable_type.present?
    end

    def validate_image_dimensions
      if attachment_of_valid_content_type?
        return true if imageable_class == Widget::Card

        dimensions = Paperclip::Geometry.from_file(attachment.queued_for_write[:original].path)
        errors.add(:attachment, :min_image_width, required_min_width: MIN_SIZE) if dimensions.width < MIN_SIZE
        errors.add(:attachment, :min_image_height, required_min_height: MIN_SIZE) if dimensions.height < MIN_SIZE
      end
    end

    def validate_attachment_size
      if imageable_class &&
         attachment_file_size > 1.megabytes
        errors[:attachment] = I18n.t("images.errors.messages.in_between",
                                      min: "0 Bytes",
                                      max: "#{imageable_max_file_size} MB")
      end
    end

    def validate_attachment_content_type
      if imageable_class && !attachment_of_valid_content_type?
        errors[:attachment] = I18n.t("images.errors.messages.wrong_content_type",
                                      content_type: attachment_content_type,
                                      accepted_content_types: imageable_humanized_accepted_content_types)
      end
    end

    def attachment_presence
      if attachment.blank? && cached_attachment.blank?
        errors[:attachment] = I18n.t("errors.messages.blank")
      end
    end

    def attachment_of_valid_content_type?
      attachment.present? && imageable_accepted_content_types.include?(attachment_content_type)
    end

    def remove_cached_attachment
      image = Image.new(imageable: imageable,
                        cached_attachment: cached_attachment,
                        user: user)
      image.set_attachment_from_cached_attachment
      image.attachment.destroy
    end

end
