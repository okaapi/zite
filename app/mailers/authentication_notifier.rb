require "singleton"

  class AuthenticationNotifier < ActionMailer::Base

    # this gets executed once when the class is initialized
    mail_config = (YAML::load( File.open(Rails.root + 'config/auth_mail.yml') ))
    self.smtp_settings = mail_config["server"].merge(mail_config["credentials"]).symbolize_keys       
    
    def registration( user, request, admins )
      @current_user = user     
      @path = ur_secrets_path( request, @current_user.token )       
      @site = request.host         
      mail to: user.email, subject: "Registration information for #{@site}",
           from: request.host + ' ' + self.smtp_settings[:sender_email],
           bcc: admins
    end

    def reset( user, request, admins )   
      @current_user = user    
      @path = ur_secrets_path( request, @current_user.token )
      @site = request.host
      mail to: user.email, subject: "Password reset information for #{@site}",
           from: request.host + ' ' + self.smtp_settings[:sender_email],
           bcc: admins    
    end
  
    def test( email, host = 'test.host' )
      mail to: email, subject: 'Okaapi test',
           from: host + ' ' + self.smtp_settings[:sender_email]
    end
  
    private
    
      def ur_secrets_path request, token
        request.protocol + request.host + ':' + request.port.to_s + '/_from_mail/' + token    
      end

  end