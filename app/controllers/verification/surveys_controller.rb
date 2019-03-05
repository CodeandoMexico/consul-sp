class Verification::SurveysController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  before_action :set_variables, only: [:new]
  skip_authorization_check

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(survey_params)
    @survey.user = current_user
    if @survey.save
      # redirect_to verified_user_path, notice: t('verification.sms.create.flash.success')
      redirect_to root_path, notice: 'Tu cuenta ha sido verificada con exito.'
    else
      render :new
    end
  end


  private

    def survey_params
      params.require(:survey).permit(:birth_date, :genre, :school_grade, :job, :salary, :recently_vote,
                                     :social_work, :attend_event, :participate_last_year,
                                     :how_discover, :promotion_text, :other_text)
    end

    def verified_user
      return false unless params[:verified_user]
      @verified_user = VerifiedUser.by_user(current_user).where(id: params[:verified_user][:id]).first
    end

    def redirect_to_next_path
      current_user.reload
      if current_user.level_three_verified?
        redirect_to account_path, notice: t('verification.sms.update.flash.level_three.success')
      else
        redirect_to new_letter_path, notice: t('verification.sms.update.flash.level_two.success')
      end
    end

    def set_variables
      @genres = [{"value"=> "male", "name"=> "Masculino"},
                 {"value"=> "female", "name"=> "Femenino"},
                 {"value"=> "other", "name"=> "Otro"}]
      @grades = [{"value"=> "none_grade", "name"=> "Ninguno"},
                {"value"=> "primary", "name"=> "Primaria"},
                {"value"=> "secundary", "name"=> "Secundaria"},
                {"value"=> "high_school", "name"=> "Preparatoria o bachillerato"},
                {"value"=> "university", "name"=> "Licenciatura o profesional"},
                {"value"=> "postgraduate", "name"=> "Posgrado"}]

      @jobs =  [{"value"=> "profesional", "name"=> "Profesionista"},
                {"value"=> "technician", "name"=> "Técnico"},
                {"value"=> "teacher", "name"=> "Trabajador de la educación"},
                {"value"=> "artist", "name"=> "Trabajador del arte, espectáculos y deporte"},
                {"value"=> "official", "name"=> "Funcionario o directivo de los sectores público, privado o social"},
                {"value"=> "farmer", "name"=> "Trabajadores en actividades agrícolas, ganaderas, silvícolas y de caza y pesca"},
                {"value"=> "fixer", "name"=> "Artesanos y trabajadores fabriles en la industria de la transformación y trabajadores en actividades de reparación y mantenimiento"},
                {"value"=> "driver", "name"=> "Conductores y ayudantes de conductores de maquinaria móvil y medios de trasporte"},
                {"value"=> "manager", "name"=> "Jefes de departamento, coordinadores y supervisores en actividades administrativas y de servicios"},
                {"value"=> "administrative", "name"=> "Trabajadores de apoyo en actividades administrativas"},
                {"value"=> "merchant", "name"=> "Comerciantes, empleados de comercio y agentes de ventas"},
                {"value"=> "personal_services", "name"=> "Trabajadores en servicios personales"},
                {"value"=> "domestic", "name"=> "Trabajadores en servicios domésticos"},
                {"value"=> "guard", "name"=> "Trabajadores en servicios de protección y vigilancia y fuerzas armadas"},
                {"value"=> "no_specific", "name"=> "Otros trabajadores con ocupaciones no especificadas"}]

      @salaries = [{"value"=> "fourth_less", "name"=> "4,000 o menos"},
                   {"value"=> "fourth_to_nine", "name"=> "4,001 a 9,000"},
                   {"value"=> "nine_to_twenty", "name"=> "9,001 a 20,000"},
                   {"value"=> "twenty_to_thirtyfive", "name"=> "20,001 a 35,000"},
                   {"value"=> "thirtyfive_to_fifty", "name"=> "35,001 a 50,000"},
                   {"value"=> "fifty_to_eighty", "name"=> "50,001 a 80,000"},
                   {"value"=> "more_of_eighty", "name"=> "80,001 o más"}]

     @votes =  [{"value"=> "yes_vote", "name"=> "Sí"},
                {"value"=> "no_vote", "name"=> "No"},
                {"value"=> "not_sure_vote", "name"=> "No estoy seguro"}]

     @social_work = [{"value"=> "yes_socialwork", "name"=> "Sí"},
                     {"value"=> "no_socialwork", "name"=> "No"},
                     {"value"=> "not_sure_socialwork", "name"=> "No estoy seguro"}]

     @attend_event = [{"value"=> "yes_attend", "name"=> "Sí"},
                      {"value"=> "no_attend", "name"=> "No"}]

     @participate_last_year = [{"value"=> "yes_participate", "name"=> "Sí"},
                              {"value"=> "no_participate", "name"=> "No"},
                              {"value"=> "not_sure_participate", "name"=> "No estoy seguro"}]

     @how_discover = [{"value"=> "news_paper", "name"=> "Periódicos"},
                      {"value"=> "promotion", "name"=> "Promoción en espacios públicos"},
                      {"value"=> "social_network", "name"=> "Redes Sociales"},
                      {"value"=> "recomendation", "name"=> "Recomendación de amigo/compañero"},
                      {"value"=> "other_medium", "name"=> "Otro"}]


    end

end
