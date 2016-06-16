class AuthenticateController < ApplicationController

  # max retries for password
  MAX_RETRIES = 3
  
  def who_are_u  
    # ask the user for their username
  end
  
  def prove_it
    
    Page.uncache_all( request.host )
    
    @claim = params[:claim]
    @password = params[:password]
    # this is for testing email failure exception code    
    @eft = params[:ab47hk]
        
    # this is the first time we come here
    if !@password
      session[:password_retries] = 0
	  
    # now the user has offered a password
    elsif @current_user = User.by_email_or_username( @claim ) 
        # if that's ok
        if @current_user.authenticate( @password )

          # and this user is confirmed, log him in, with a new session
          if @current_user.confirmed?                	  
            create_new_user_session( @current_user, session[:last_page] )	
            redirect_to_page_js_or_html( {notice: "#{@current_user.username} logged in" },
		                             session[:last_page] )				
          else
            # else let him now he needs to activate
            redirect_to_page_js_or_html alert: "user is not activated, check your email (including SPAM folder)"
          end            
        else
          
          # ok, let him try again, but only twice          
          if session[:password_retries] >= (@max_retries = MAX_RETRIES)
            # third time... suspend the user
            @current_user.suspend_and_save
            @current_user.token = nil if @eft == 'ab47hk'
            begin
              # and send him an email
              AuthenticationNotifier.reset(@current_user, request, User.admin_emails).deliver_now           
              reset_session
              redirect_to_page_js_or_html alert: "user suspended, check your email (including SPAM folder)"
            rescue Exception => e         
              redirect_to_page_js_or_html alert: "user suspended, but email sending failed 3 #{e}"
            end
          else
            # else try again but increment the retries (also in the session object)
            @retries = (session[:password_retries] += 1)
          end 
        end
  
    else
	  session[:password_retries]||= 0
	  @retries = ( session[:password_retries] += 1 )
	  if session[:password_retries] >= (@max_retries = MAX_RETRIES)
        redirect_to_page_js_or_html alert: "password for \"#{@claim}\" is incorrect!"
     end
    end    
    
  end

  def about_urself
    
    @username = params[:username]
    @email = params[:email] 
    # this is for testing email failure exception code
    @eft = params[:ab47hk]
    
    # if email and username are given... otherwise this is the empty dialogue (first time)
    if @email and @username
      # create this new user, but in unconfirmed status
      @current_user = User.new_unconfirmed( @email, @username )
      @current_user.token = nil if @eft == 'ab47hk'
      if @current_user.save  
        begin  
          AuthenticationNotifier.registration(@current_user,request,User.admin_emails).deliver_now  
          redirect_to_page_js_or_html notice: "Please check your email #{@email} (including your SPAM folder) for an email to verify it's you and set your password!"
        rescue Exception => e
          @current_user.destroy if @current_user
          redirect_to_page_js_or_html alert: "we sent an activation email, but it failed 1 (#{e})."
        end
      end
    end
    
  end
  
  def from_mail # get
    
    # this is the link from the email... set the reset_user_id, and immediately redirect
    # redirection will show the ur_secrets dialogue with form to ur_secrets
    Page.uncache_all( request.host )
    @user_token = params[:user_token]
    if @current_user = User.by_token( @user_token )
      # REMEMBER this user _id for ur_secrets!
      session[:reset_user_id] = @current_user.id
      redirect_to_root_html  alert: "please set your password"
    else
      redirect_to_root_html alert: "the activation link is incorrect, please reset..."
    end      
    
  end
  
  def ur_secrets # post
    
    # this is to set the password, must be coming from from_mail
    # immeditately set reset_user_id to nil
    if user_id = session[:reset_user_id] 
      session[:reset_user_id] = nil
    else
      # if there is a problem with the password input, we come back here, with user_id set
      user_id = params[:user_id]
    end
       
    # set the new password
    if @current_user = User.by_id( user_id )
      @current_user.password = params[:password]
      @current_user.password_confirmation = params[:password_confirmation] 
      @current_user.active = 'confirmed'
      @current_user.token = nil
      if @current_user.save # succes!
        create_new_user_session( @current_user, session[:last_page] )   
        redirect_to_page_js_or_html notice: "password set, you are logged in!"
      end
    else
      redirect_to_page_js_or_html alert: "leopards in the bushes!"  # something is reaaalllyyy wrong
    end

  end
  
  def reset_mail
    
    # reset the session object and suspend the user, with email
    reset_session  
    if user = User.by_email_or_username( params[:claim] ) 
      begin
        user.suspend_and_save
        AuthenticationNotifier.reset(user, request,User.admin_emails).deliver_now        
        redirect_to_root_html notice: "user #{user.username} suspended, check your email (including SPAM folder)"
      rescue Exception => e           
        redirect_to_root_html alert: "user suspended, but email sending failed 2 #{e}"
      end        
    else
      redirect_to_root_html
    end
    
  end

  def see_u
    # reset the session object, and forget the user that way
    reset_session  
    redirect_to_root_html
  end
  
  

      
  private
    
    def redirect_to_page_js_or_html( flash_content = nil, page = nil )
      if flash_content
        flash[ flash_content.keys[0] ] = flash_content[ flash_content.keys[0] ]
        flash.keep[ flash_content.keys[0] ]
      end
      if Rails.configuration.use_javascript
        render js: "window.location = #{page}"
      else 
        redirect_to '/' + ( page || '' )
      end
    end
    def redirect_to_root_html flash_content = nil
      if flash_content
        flash[ flash_content.keys[0] ] = flash_content[ flash_content.keys[0] ]
        flash.keep[ flash_content.keys[0] ]
      end
      redirect_to '/'
    end
    
    def create_new_user_session( user, last_page )   
      reset_session
	  session[:last_page] = last_page
      Page.uncache_all( request.host )
      user_session = UserSession.new_ip_and_client( user, request.remote_ip(),
                                                   request.env['HTTP_USER_AGENT'])
      session[:user_session_id] = user_session.id     
      UserAction.add_action( user_session.id, controller_name, action_name, params )            
    end
  
end
