require 'net/http'

class AuthenticateController < ApplicationController

  # max retries for password
  MAX_RETRIES = 3
  
  def fb_login
    
    uncache_all
    
    login_from = session[:login_from]
    
    authentication_logger('---')
    authentication_logger('start of fb_login')        
    authentication_logger("  logged in from page #{login_from}")
    
    #
    #  begin
    # 
    begin
    
      url = URI.parse('https://graph.facebook.com/me?fields=name,email&access_token=' + params[:fb_token] )
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'
      http.read_timeout = 1  # set this to zero to check time out... or 'http://httpstat.us/200?sleep=3000'
      http.open_timeout = 1
      
      authentication_logger('checking access_token with Facebook...')
      resp = http.start() {|http| http.get(url) }
      
      authentication_logger('   ...done')      
      parsed_resp = JSON.parse(resp.body)

      if ! parsed_resp['error']
      
        fb_email = parsed_resp['email']
        fb_name = parsed_resp['name']
        authentication_logger("fb email #{fb_email} name #{fb_name}")	
        
        @current_user = User.by_email_or_username( fb_email ) 

        # 
        #  if @current_user exists, i.e. there is a user with the facebook email
        #
        if @current_user

          # 
          #   and this user is confirmed, log him in, with a new session
          #
          if @current_user.confirmed?           	  
            create_new_user_session( @current_user )	
            redirect_to_action_html( { notice: "#{@current_user.username} logged in from Facebook" }, login_from )		        
          else
            # else let him know he needs to activate
            redirect_to_action_html( { alert: "user is not activated, check your email (including SPAM folder)" }, 
                                           login_from )
          end
        #
        #  if there is no user with this email
        #     
        else
        
          authentication_logger("fb email not known #{fb_email}")	
        
          if fb_email and fb_name
            # create this new user, but in unconfirmed status
            @current_user = User.new_confirmed( fb_email, fb_name )
            if @current_user.save
              begin  
                create_new_user_session( @current_user )
                redirect_to_action_html notice: "new user #{@current_user.username} created and logged in from Facebook"
              rescue Exception => e
                @current_user.destroy if @current_user
                redirect_to_action_html alert: "tried to create user #{fb_email} from Facebook but failed (#{e})."
              end
            end
          end
                  
          #redirect_to_action_html( { alert: "no user with Facebook email #{fb_email}" + 
          #                         " (you may be logged into Facebook with a different account in another browser tab)" }, 
          #                         login_from )
        end    
        
      else
      
        authentication_logger("fb email error {parsed_resp['error']['message']}")	
        
        redirect_to_action_html( { alert: "login from Facebook failed #{parsed_resp['error']['message']}" },
                                         login_from )
      end
      
    rescue => e  # could also use Net::ReadTimeout => e
        
      authentication_logger("fb email error {e.message}")
      
      redirect_to_action_html( { alert: "login from Facebook failed #{e.message}" }, 
                                       login_from)
                                         
    end    
    
  end
  
  def who_are_u  
    # ask the user for their username
	a = request.headers['HTTP_REFERER']	
	login_from = a[a.rindex('/')+1..a.length] if a
	
	if defined?( Page )
	  session[:login_from] = login_from if Page.get_latest( login_from )
	else 
	  session[:login_from] = login_from
	end
	 
    authentication_logger("who_are_u from page #{session[:login_from]}")	
  end

  def prove_it
    	
    uncache_all
    
    login_from = session[:login_from]
    
    authentication_logger('---')
    authentication_logger('start of prove_it')        
    authentication_logger("  logged in from page #{login_from}")

    @claim = params[:claim]
    @password = params[:kennwort]
    # this is for testing email failure exception code    
    @eft = params[:ab47hk]
        
    # this is the first time we come here
    if !@password
      session[:password_retries] = 0
	  
      authentication_logger('no password')   
    
    # now the user has offered a password
    elsif @current_user = User.by_email_or_username( @claim ) 

        authentication_logger("user #{@claim} exists")   

        # if that's ok
        if @current_user.authenticate( @password )

          authentication_logger("user authenticated")   

          # and this user is confirmed, log him in, with a new session
          if @current_user.confirmed?          

            authentication_logger("user is confirmed")   
  	       
            create_new_user_session( @current_user )	
            redirect_to_action_html( { notice: "#{@current_user.username} logged in" }, login_from )		
            
          else
            # else let him know he needs to activate

            authentication_logger("user is NOT confirmed")   

            redirect_to_action_html( { alert: "user is not activated, check your email (including SPAM folder)" }, 
                                           login_from )
          end
          
        else
          
          authentication_logger("authenticated problem")   

          # ok, let him try again, but only twice          
          if session[:password_retries] >= (@max_retries = MAX_RETRIES)
            
            authentication_logger('exceeded max retries - user will be suspended')  
            
            # third time... suspend the user
            @current_user.suspend_and_save
            @current_user.token = nil if @eft == 'ab47hk'
            begin
              # and send him an email
              AuthenticationNotifier.reset(@current_user, request, User.admin_emails).deliver_now           
              reset_session
              redirect_to_action_html( { alert: "user suspended, check your email (including SPAM folder)"},
                                             login_from )
            rescue Exception => e         
              redirect_to_action_html( { alert: "user suspended, but email sending failed 3 #{e}"},
                                             login_from )
            end
          else
            
            authentication_logger('try again')  
            
            # else try again but increment the retries (also in the session object)
            @retries = (session[:password_retries] += 1)
          end 
        end
  
    else

        authentication_logger('user not found')  

        session[:password_retries] ||= 0
        @retries = ( session[:password_retries] += 1 )
        if session[:password_retries] >= (@max_retries = MAX_RETRIES)
          redirect_to_action_html( { alert: "password for \"#{@claim}\" is incorrect!" }, 
                                           login_from )
        end
    end    

    authentication_logger('at the end of prove_it')  
    
  end

  def about_urself
    
    uncache_all

    authentication_logger('---')
    authentication_logger('start of about urself')  
    
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
          redirect_to_action_html notice: "Please check your email #{@email} (including your SPAM folder) for an email to verify it's you and set your password!"
        rescue Exception => e
          @current_user.destroy if @current_user
          redirect_to_action_html alert: "we sent an activation email, but it failed 1 (#{e})."
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
        redirect_to_action_html notice: "password set, you are logged in!"
      end
    else
      redirect_to_action_html alert: "leopards in the bushes!"  # something is reaaalllyyy wrong
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
	
	a = request.headers['HTTP_REFERER']	
	session[:login_from] = a[a.rindex('/')+1..a.length] if a
    authentication_logger('see_u from #{session[:login_from]}')	
        
    reset_session
    redirect_to_root_html notice: "logged out"
  end
       
  def check
    if params[:code].to_i == 17706
      @session = session
	else	
	  redirect_to root_path
	end
  end
  
  def clear
    reset_session
	redirect_to root_path, alert: "session reset..."
  end
         
  private
    
    def redirect_to_action_html( flash_content = nil, page = nil )
    
      authentication_logger('redirect_to_action_html')  

      if flash_content
        flash[ flash_content.keys[0] ] = flash_content[ flash_content.keys[0] ]
        flash.keep[ flash_content.keys[0] ]
        authentication_logger( flash[ flash_content.keys[0] ] )  
      end                 

      redirect_to '/' + ( page || '' )
      
    end
    
    def redirect_to_root_html( flash_content = nil )
        
      authentication_logger('redirect_to_root_html')        
          
      if flash_content
        flash[ flash_content.keys[0] ] = flash_content[ flash_content.keys[0] ]
        flash.keep[ flash_content.keys[0] ]
        authentication_logger( flash[ flash_content.keys[0] ] )         
      end      
      
      redirect_to '/'
    end
    
    def create_new_user_session( user )   

      reset_session
      uncache_all
      user_session = UserSession.new_ip_and_client( user, request.remote_ip(),
                                                   request.env['HTTP_USER_AGENT'])
      session[:user_session_id] = user_session.id     
      UserAction.add_action( user_session.id, controller_name, action_name, params )            
    end
  
    def uncache_all
      Page.uncache_all( request.host ) if defined?( Page )
    end
    
    def authentication_logger( str )
      #
      #  uncomment to turn on logging
      #  logger.info( 'AUTHENTICATE_CONTROLLER ' + str ) if str
      #
    end

end
