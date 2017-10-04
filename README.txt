
1) Need to experiment with the :random option
config.active_support.test_order = :sorted

2) Forget why we had to comment this out, let's revisit
####protect_from_forgery with: :exception
  #skip_before_action :verify_authenticity_token #, only: :file_upload
 
3) caching for site_mapped sites... turn off again

4) do we still have logins onto a cached index page?

5) for users - last login

6) Facebook user generation - email to wido, trixi

7) directory list in camera is still wrongly ordered (should not be date of file)

8) there should not be a heading for camera if there are no files in it!

