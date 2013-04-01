Uwcshop::Application.routes.draw do

  match '/search/' => 'search#show'
  match '/category/:category/:data' => 'category#show'
  match '/:category/:product_id' => 'product#show'

  root :to => 'welcome#index'
end
