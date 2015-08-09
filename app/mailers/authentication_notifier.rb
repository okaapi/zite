require "singleton"

  class AuthenticationNotifier < ActionMailer::Base

    # this gets executed once when the class is initialized
    mail_config = (YAML::load( File.open(Rails.root + 'config/auth_mail.yml') ))
    self.smtp_settings = mail_config["server"].merge(mail_config["credentials"]).symbolize_keys
    
    default from: smtp_settings[:sender_email]
    
    def registration( user, request )
      @current_user = user
      @path = ur_secrets_path( request, @current_user.token )
      mail to: user.email, subject: 'Okaapi registration confirmation' 
    end

    def reset( user, request )   
      @current_user = user    
      @path = ur_secrets_path( request, @current_user.token )
      mail to: user.email, subject: 'Okaapi password reset'
    end
  
    def test( email )
      mail to: email, subject: 'Okaapi test'
    end
  
    private
    
      def ur_secrets_path request, token
        request.protocol + request.host + ':' + request.port.to_s + '/_from_mail/' + token    
      end

  end

