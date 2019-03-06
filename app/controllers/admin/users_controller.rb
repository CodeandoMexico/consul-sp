class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @users = User.by_username_email_or_document_number(params[:search]) if params[:search]
    @all_users = @users
    @users = @users.page(params[:page])
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data @all_users.order('created_at DESC').to_csv, filename: "usuarios-#{Date.today}.csv"}
    end
  end
end
