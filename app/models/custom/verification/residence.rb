
require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence
  def postal_code_in_madrid
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residence_in_madrid
    return true

    # TODO aqui vamos a buscar la carta catastral
    # aqui vas a validar la carta catastral
    # return if errors.any?
    #
    # unless residency_valid?
    #   errors.add(:residence_in_madrid, false)
    #   store_failed_attempt
    #   Lock.increase_tries(user)
    # end
  end

  private

    def valid_postal_code?
      # Zipcode.where(postal_code: postal_code).exists?
      postal_code =~ /^662/ # TODO prefijo de san pedro
    end

end
