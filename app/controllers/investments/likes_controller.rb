class Investments::LikesController  < ApplicationController
  before_action :authenticate_user!
  before_action :set_investment
  skip_authorization_check

def create
  @investment.likes.where(user_id: current_user.id).first_or_create

  respond_to do |format|
    format.js
  end
end


def destroy
  @investment.likes.where(user_id: current_user.id).destroy_all
  respond_to do |format|
    format.js
  end
end

  def set_investment
    @investment = Budget::Investment.find(params[:investment_id])
  end
end
