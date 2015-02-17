Rails.application.routes.draw do
	root 'index#index'
	get '/data', to: 'index#data'
end
