class VerificationController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_lock

  skip_authorization_check

  def show
    redirect_to next_step_path[:path], notice: next_step_path[:notice]
  end

  private

    def next_step_path(user = current_user)
      if user.organization?
        { path: account_path }
      elsif user.level_three_verified? # survey completo
        { path: account_path, notice: t('verification.redirect_notices.already_verified') }
      elsif user.level_two_verified? # direccion asignada con catastral
        { path: new_survey_path } # TODO es el paso del telofono, personalizar verificacion
      elsif user.residence_verified? #numero de registro lleno
        { path: new_address_user_path }
      elsif user.verification_email_sent?
        { path: verified_user_path, notice: t('verification.redirect_notices.email_already_sent') }
      elsif user.residence_verified?
        { path: verified_user_path }
      else
        { path: new_residence_path }
      end
    end

end
