class Verification::VerifiedUserController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_verified!
  skip_authorization_check

  def show
    @verified_users = VerifiedUser.by_user(current_user)
    # redirect_to new_sms_path unless user_data_present?
    # Here you redirect to the survey path
    if current_user.survey.present?
      redirect_to_next_path
    elsif current_user.address_user.present?
      redirect_to new_survey_path
    elsif current_user.address_user.blank?
      redirect_to new_address_user_path
    else
      #redirect_to new_survey_path unless user_data_present?
      redirect_to new_address_user_path unless user_data_present?
    end
  end

  private

    def user_data_present?
      return false if @verified_users.blank?

      data = false
      @verified_users.each do |vu|
        # data = true if vu.phone.present? || vu.email.present?
        data = true if vu.survey.present? || vu.email.present?
      end

      data
    end

    def redirect_to_next_path
      current_user.reload
      if current_user.level_three_verified?
        redirect_to account_path, notice: t('verification.sms.update.flash.level_three.success')
      else
        redirect_to new_letter_path, notice: t('verification.sms.update.flash.level_two.success')
      end
    end

end
