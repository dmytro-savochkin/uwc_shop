Uwcshop::Application.routes.draw do

  post '/search/' => 'search#show'
  match '/category/:category_link/' => 'category#show'
  match '/:category_link/:link/:product_id' => 'product#show'

  root :to => 'welcome#index'
end
