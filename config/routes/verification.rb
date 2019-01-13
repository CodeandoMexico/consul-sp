scope module: :verification do
  resource :residence, controller: "residence", only: [:new, :create]
  resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
  resource :survey, controler: "survey", only: [:new, :create] # for survey actions
  resource :address_user, controler: "address_user", only: [:new, :create] # for user_address actions
  resource :verified_user, controller: "verified_user", only: [:show]
  resource :email, controller: "email", only: [:new, :show, :create]
  resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
end

resource :verification, controller: "verification", only: [:show]
