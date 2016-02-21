
1) Need to experiment with the :random option
config.active_support.test_order = :sorted

2) Forget why we had to comment this out, let's revisit
####protect_from_forgery with: :exception
  #skip_before_action :verify_authenticity_token #, only: :file_upload
 
3) Remove these comments - they had to do with test experiments
 ###comments in application_controller.rb 
 
4) the current mysql2 gem did not work, so using this for now
gem 'mysql2', '~> 0.3.18'

5) Rails 5 migrations
  # config.serve_static_files  = true
  config.public_file_server.enabled = true
  # config.static_cache_control = 'public, max-age=3600'
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600'}
  
  before_action instead of before_filter
  application_controller.rb