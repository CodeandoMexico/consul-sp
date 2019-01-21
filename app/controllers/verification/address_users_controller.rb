# frozen_string_literal: true

class Verification::AddressUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_verified!
  before_action :verify_lock, only: %i[new create]
  skip_authorization_check

  def new
    @address_user = AddressUser.new
  end

  def create
    @address_user = AddressUser.new(user_address_params)
    @address_user.user = current_user
    if @address_user.save
      # TODO: mensajes nuevos
      # redirect_to verified_user_path, notice: t('verification.sms.create.flash.success')
      redirect_to verified_user_path
    else
      render :new
    end
  end

  private

  def user_address_params
    # params.require(:address_user_confirm).permit(address_user: [:latitude, :longitude, :zoom])
    params.require(:address_user_confirm).require(:address_user).permit!
  end

  def verified_user
    return false unless params[:verified_user]
    @verified_user = VerifiedUser.by_user(current_user).where(id: params[:verified_user][:id]).first
  end
end
