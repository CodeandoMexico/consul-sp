class ApiController < ApplicationController
  skip_authorization_check :only => [:image_upload]

  def image_upload
    @user = User.find(user_params)
    file = open(img_params.first.last.tempfile)
    @user.ife = file
    if @user.save!
      render :json => {:status => 'success'}
    else
      render :json => {:status => 'fail'}
    end
  end

  private

  def img_params
      params.require(:image).permit(:image)
  end

  def user_params
      params.require(:user_id)
  end
end
