# frozen_string_literal: true

class Verification::AddressUsersController < ApplicationController
  include CustomMethods

  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_verified!
  before_action :set_polygon, only: %i[create]
  before_action :set_junta_vecinal, only: %i[create]
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

  def set_polygon
    catastral = Catastral.where(exped: current_user.document_number).first
    latitude = params[:address_user_confirm][:address_user][:latitude]
    longitude = params[:address_user_confirm][:address_user][:longitude]

    current_location = Geokit::LatLng.new(latitude,longitude)

    #fix fix fix
    catastral.latitude= 0 if catastral.latitude.nil?
    catastral.longitude= 0 if catastral.longitude.nil?

    destination = "#{catastral.latitude},#{catastral.longitude}"

    distance = current_location.distance_to(destination)

    return if current_user.sector != 'MANUAL' && distance < 1

    sector = get_polygon(latitude, longitude)
    current_user.update_column(:sector, sector)

    current_user.geozone = Geozone.where(census_code: sector).first
    current_user.save!
    # update catastral info
    catastral.update_column(:latitude, latitude)
    catastral.update_column(:longitude, longitude)
    catastral.update_column(:district_code, sector)
    catastral.update_column(:registers, (catastral.registers + 1))

  end

  def set_junta_vecinal
    latitude = params[:address_user_confirm][:address_user][:latitude]
    longitude = params[:address_user_confirm][:address_user][:longitude]
    junta_vecinal = Colonium.where("ST_DWithin(the_geom, 'POINT(#{longitude} #{latitude})',0.0000621371)").first
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
