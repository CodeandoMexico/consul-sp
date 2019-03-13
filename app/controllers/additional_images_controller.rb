class AdditionalImagesController < ApplicationController
  skip_authorization_check only: :destroy

  def destroy
    @additional_image = AdditionalImage.find(params[:id])
    @additional_image.destroy

    render json: {}, status: 200
  end
end
