class MyVotesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource class: "User"

  def index
    redirect_to user_path(@current_user, filter: 'votes')
  end
end
