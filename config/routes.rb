Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

  # Static pages
	root		'static_pages#home'
	get			'/help', 	to: 'static_pages#help'
	get 		'/about', 	to: 'static_pages#about'
	get 		'/contact', to: 'static_pages#contact'

	# Dynamic pages
	get 		'/signup', 	to: 'users#new'
	post 		'/signup', 	to: 'users#create'
	get 		'/login', 	to: 'sessions#new'
	post 		'/login', 	to: 'sessions#create'
	delete		'/logout', 	to: 'sessions#destroy'
	resources :users do
		member do # member method arranges for the routes to respond to URLs containing the user id.
		# collection do # works without the id.
			get :following, :followers # get method arranges for GET request to URLs of the form users/[id]/following.
		end
	end
	resources :account_activations, only: [:edit]
	resources :password_resets, only: [:new, :create, :edit, :update]
	resources :microposts, only: [:create, :destroy]
	resources :relationships, only: [:create, :destroy]
	
	# Avoid crash when refreshing page after failed micropost submission.
	get '/microposts', to: 'static_pages#home'
end

