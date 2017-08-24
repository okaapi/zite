class AuthenticateController < ApplicationController

  # max retries for password
  MAX_RETRIES = 3
  
  def who_are_u  
    # ask the user for their username
	a = request.headers['HTTP_REFERER']
	session[:login_from] = a[a.rindex('/')+1..a.length] if a
  end
  
  def prove_it
    	
    uncache_all
    
    session[:text] = "reset at the start of prove_it <br>" if !session[:text]
    session[:text] += "start of prove_it <br>"

    @claim = params[:claim]
    @password = params[:kennwort]
    # this is for testing email failure exception code    
    @eft = params[:ab47hk]
        
    # this is the first time we come here
    if !@password
      session[:password_retries] = 0
	  
      session[:text] += "no password <br>"
    
    # now the user has offered a password
    elsif @current_user = User.by_email_or_username( @claim ) 

        session[:text] += "user exists <br>"

        # if that's ok
        if @current_user.authenticate( @password )

          session[:text] += "user authenticated <br>"

          # and this user is confirmed, log him in, with a new session
          if @current_user.confirmed?          

            session[:text] += 'user confirmed <br>'

            login_from = session[:login_from]      	  
            session_text = session[:text]
            create_new_user_session( @current_user )	
            session[:text] = session_text
            redirect_to_action_js_or_html( { notice: "#{@current_user.username} logged in" }, login_from )		
          else
            # else let him know he needs to activate

            session[:text] += 'user NOT confirmed <br>'

            redirect_to_action_js_or_html( { alert: "user is not activated, check your email (including SPAM folder)" }, 
                                           login_from )
          end            
        else
          
          session[:text] += 'authentication problem <br>'

          # ok, let him try again, but only twice          
          if session[:password_retries] >= (@max_retries = MAX_RETRIES)
            # third time... suspend the user
            @current_user.suspend_and_save
            @current_user.token = nil if @eft == 'ab47hk'
            begin
              # and send him an email
              AuthenticationNotifier.reset(@current_user, request, User.admin_emails).deliver_now           
              session_text = session[:text]
              reset_session
              session[:text] = session_text
              redirect_to_action_js_or_html alert: "user suspended, check your email (including SPAM folder)"
            rescue Exception => e         
              redirect_to_action_js_or_html alert: "user suspended, but email sending failed 3 #{e}"
            end
          else
            session[:text] += 'try again <br>'
            # else try again but increment the retries (also in the session object)
            @retries = (session[:password_retries] += 1)
          end 
        end
  
    else

        session[:text] += 'user not found <br>'

        session[:password_retries] ||= 0
        @retries = ( session[:password_retries] += 1 )
        if session[:password_retries] >= (@max_retries = MAX_RETRIES)
          redirect_to_action_js_or_html alert: "password for \"#{@claim}\" is incorrect!"
        end
    end    

    session[:text] = "reset at the end of prove_it <br>" if !session[:text]
    session[:text] += "end of prove it <br><br>"
    
  end

  def about_urself
    
    uncache_all

    session[:text] = "reset at the beginning of about_urself  <br>" if !session[:text]
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
          redirect_to_action_js_or_html notice: "Please check your email #{@email} (including your SPAM folder) for an email to verify it's you and set your password!"
        rescue Exception => e
          @current_user.destroy if @current_user
          redirect_to_action_js_or_html alert: "we sent an activation email, but it failed 1 (#{e})."
        end
      end
    end
    
  end
  
  def from_mail # get
    
    # this is the link from the email... set the reset_user_id, and immediately redirect
    # redirection will show the ur_secrets dialogue with form to ur_secrets
    
    uncache_all
    
    @user_token = params[:user_token]
    if @current_user = User.by_token( @user_token )
      # REMEMBER this user _id for ur_secrets!
      session[:reset_user_id] = @current_user.id
      redirect_to_root_html alert: "please set your password"
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
      @current_user.password = params[:kennwort]
      @current_user.password_confirmation = params[:confirmation] 
      @current_user.confirm
      @current_user.token = nil
      if @current_user.save # succes!
        create_new_user_session( @current_user )   
        redirect_to_action_js_or_html notice: "password set, you are logged in!"
      end
    else
      redirect_to_action_js_or_html alert: "leopards in the bushes!"  # something is reaaalllyyy wrong
    end

  end
  
  def reset_mail
    
    # reset the session object and suspend the user, with email
    reset_session  
    if user = User.by_email_or_username( params[:claim] ) 
      begin
        user.suspend_and_save
        AuthenticationNotifier.reset(user, request, User.admin_emails).deliver_now        
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
    session_text = session[:text]
    reset_session
    redirect_to_root_html
  end
       
  private
    
    def redirect_to_action_js_or_html( flash_content = nil, page = nil )
      session[:text] = "reset at start of redirect_to_action_js_or_html <br>" if !session[:text]
      session[:text] += "redirect_to_action_js_or_html <br>"
      if flash_content
        flash[ flash_content.keys[0] ] = flash_content[ flash_content.keys[0] ]
        flash.keep[ flash_content.keys[0] ]
      end
      session[:text] += 'flash = ' + flash.keep[ flash_content.keys[0] ] + ' <br>'
      if Rails.configuration.use_javascript
        session[:text] += "render window.location <br>"
        render js: "window.location = #{page}"
      else 
        session[:text] += "redirect_to <br>"
        redirect_to '/' + ( page || '' )
      end
      session[:text] += "redirect_to_action_js_or_html end <br>"
    end
    
    def redirect_to_root_html( flash_content = nil )
      if flash_content
        flash[ flash_content.keys[0] ] = flash_content[ flash_content.keys[0] ]
        flash.keep[ flash_content.keys[0] ]
      end
      redirect_to '/'
    end
    
    def create_new_user_session( user )   
      session_text = session[:text]
      reset_session
      session[:text] = session_text
      uncache_all
      user_session = UserSession.new_ip_and_client( user, request.remote_ip(),
                                                   request.env['HTTP_USER_AGENT'])
      session[:user_session_id] = user_session.id     
      UserAction.add_action( user_session.id, controller_name, action_name, params )            
    end
  
    def uncache_all
      Page.uncache_all( request.host ) if defined?( Page )
    end

end
