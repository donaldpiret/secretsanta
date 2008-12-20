ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'dashboards', :action => 'show'
  map.login '/login', :controller => 'sessions', :action => 'new'
  
  map.resource :dashboard, :session
  map.resources :users, :collection => {:pick => :post}
end
