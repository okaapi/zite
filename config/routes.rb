Rails.application.routes.draw do



  resources :pages

  mount Auth::Engine => "/", as: "auth_engine"
  
  root "seite#index", as: "root"
  
  get '_pageupdate/(:seite)' => 'seite#pageupdate', as: 'page_update'
  post '_pageupdate/(:seite)' => 'seite#pageupdate_save', as: 'page_update_save'
  post 'file_upload' => 'seite#file_upload', as: 'file_upload'
  post 'file_delete' => 'seite#file_delete', as: 'file_delete'
  
  get '(:seite)' => "seite#index", as: 'seite'

end
