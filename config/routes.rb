Rails.application.routes.draw do

  get 'api/image_upload'

  mount Ckeditor::Engine => '/ckeditor'

  if Rails.env.development? || Rails.env.staging?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  draw :account
  draw :admin
  draw :annotation
  draw :budget
  draw :comment
  draw :community
  draw :debate
  draw :devise
  draw :direct_upload
  draw :document
  draw :graphql
  draw :legislation
  draw :management
  draw :moderation
  draw :notification
  draw :officing
  draw :poll
  draw :proposal
  draw :related_content
  draw :tag
  draw :user
  draw :valuation
  draw :verification

  root 'welcome#index'

  get '/welcome', to: 'welcome#welcome'
  get '/consul.json', to: "installation#details"


  #API TO UPLOAD THE IFE
  put 'api/image_upload' => 'api#image_upload', as: :image_upload

  #TO UPLOAD ADDITIONAL IMAGES
  resources :additional_images, only: [:index, :create, :destroy]


  resources :stats, only: [:index]
  resources :images, only: [:destroy]
  resources :documents, only: [:destroy]
  resources :follows, only: [:create, :destroy]

  get '/mis_votos', to: 'my_votes#index'

  # More info pages
  get 'ayuda',             to: 'pages#show', id: 'help/index',             as: 'help'
  get 'help/how-to-use',  to: 'pages#show', id: 'help/how_to_use/index',  as: 'how_to_use'
  get 'ayuda/preguntas-frecuentes',         to: 'pages#show', id: 'help/faq/index',         as: 'faq'

  # Static pages
  get '/blog' => redirect("http://blog.consul/")
  resources :pages, path: '/', only: [:show]
end
