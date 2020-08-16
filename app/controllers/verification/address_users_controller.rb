# frozen_string_literal: true

class Verification::AddressUsersController < ApplicationController
  include CustomMethods

  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_verified!
  before_action :set_junta_vecinal, only: %i[create]
  before_action :verify_lock, only: %i[new create]
  skip_authorization_check

  def new
    if params[:address_user] && params[:address_user][:full_address]
      search = params[:address_user][:full_address]
      geokit_search = Geokit::Geocoders::GoogleGeocoder.geocode search
      @address_user = AddressUser.new latitude: geokit_search.latitude, longitude: geokit_search.longitude
    else
      @address_user = AddressUser.new latitude: current_user.electoral_roll.latitude, longitude: current_user.electoral_roll.longitude
    end
    @map_location = MapLocation.new(
      latitude: @address_user.latitude,
      longitude: @address_user.longitude
    )
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

  def set_junta_vecinal
    latitude = params[:address_user_confirm][:address_user][:latitude]
    longitude = params[:address_user_confirm][:address_user][:longitude]
    junta_vecinal = Colonium.find_by(
      "ST_DWithin(the_geom, 'POINT(#{longitude} #{latitude})',0.0000621371)"
    )
    if junta_vecinal.nil?
      redirect_to request.referrer, alert: "No Encontramos tu dirección en el mapa, intenta de nuevo"
    else
      user = current_user
      user.colonium_ids = junta_vecinal.id
      user.save!
    end
  end

  def user_address_params
    # params.require(:address_user_confirm).permit(address_user: [:latitude, :longitude, :zoom])
    params.require(:address_user_confirm).require(:address_user).permit!
  end

  def verified_user
    return false unless params[:verified_user]
    @verified_user = VerifiedUser.by_user(current_user).where(id: params[:verified_user][:id]).first
  end
end
