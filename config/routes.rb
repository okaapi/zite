Rails.application.routes.draw do
  
  # these are the actions related to authentication
  get "_who_are_u" => "authenticate#who_are_u", as: 'who_are_u'
  match "_prove_it" => "authenticate#prove_it", as: 'prove_it', via: [:get, :post] 
  match "_about_urself" => "authenticate#about_urself", as: 'about_urself', via: [:get, :post] 
  get "_from_mail/(:user_token)" => "authenticate#from_mail", as: 'from_mail'
  match "_ur_secrets" => "authenticate#ur_secrets", as: "ur_secrets", via: [:get, :post] 
  get "_reset_mail" => "authenticate#reset_mail", as: 'reset_mail'
  get "_see_u" => "authenticate#see_u", as: 'see_u'
  get 'testfb' => "authenticate#testfb", as: 'testfb'  
  get '_fb_login/:fb_token' => "authenticate#fb_login", as: 'fb_login'
  get '_check/(:code)' => 'authenticate#check', as: 'check'  
  get '_clear' => 'authenticate#clear', as: 'clear'     
    
  # these should only be available to administrators...
  scope module: 'admin' do  
  
    # for authentication  
    resources :users
    get 'users/:id/role_change/:role' => 'users#role_change', as: 'role_change'    
    resources :user_actions
    resources :user_sessions  
    get 'stats' => 'user_sessions#stats', as: 'stats'    
    resources :pages 
    resources :site_maps   
  end
  
  # these are the actual routes for editing
  get '_pageupdate/(:seite)' => 'seite#pageupdate', as: 'page_update'
  post '_pageupdate/(:seite)' => 'seite#pageupdate_save', as: 'page_update_save'
  post 'file_upload' => 'seite#file_upload', as: 'file_upload'
  post 'file_delete' => 'seite#file_delete', as: 'file_delete'
  get 'camera_directory_delete/(:filter)/(:date)' => 'seite#camera_directory_delete', as: 'camera_directory_delete'
  
  # route for searching
  match '_search/(:term)' => 'seite#search', as: 'search', via: [:get, :post] 
  
  # this is the route for viewing
  get '(:seite)' => "seite#index", as: 'seite'

  root "seite#index", as: "root"
  
end
