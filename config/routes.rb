Rails.application.routes.draw do
  get 		'sessions/new'

  # Static pages
	root		'static_pages#home'
	get			'/help', 	to: 'static_pages#help'
	get 		'/about', 	to: 'static_pages#about'
	get 		'/contact', to: 'static_pages#contact'

	# Dynamic pages
	get			'#',				to: 'users#index'
	get			'#',				to: 'users#show' 
	get 		'/signup', 	to: 'users#new'
	post 		'/signup', 	to: 'users#create'
	get 		'/login', 	to: 'sessions#new'
	post 		'/login', 	to: 'sessions#create'
	delete	'/logout', 	to: 'sessions#destroy'
	#get			'/edit',		to: 'users#edit'
	#patch		'/update',	to: 'users#update'
	delete	'#',				to: 'users#destroy'
	resources :users
end

