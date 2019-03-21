class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource
  skip_authorize_resource :only => [:edit, :update]
  before_action :clean_colonium, :only => :update

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

  def edit
  end

  def update
    #release
    @colonia = Colonium.find(params[:user][:colonium])
    @user.colonium << @colonia
    @user.sector = @colonia.sector

    if @user.save!
      redirect_to admin_users_path,
                  notice: "Se actualizo Usuario con exito"
    else
      flash.now[:error] = "Ocurrio un error no se pudo actualizar"
      render :edit
    end

  end

  private

  def clean_colonium
    @user.colonium = []
  end

end
