
  class UserSession < ZiteActiveRecord
    
    attr_accessor :remember_token
    belongs_to :user
    validate :id_valid
    
    has_many :user_actions, dependent: :destroy  
	
	def _user	
	  # overriding this in because it fails with scope
	  User.by_id( user_id )
	end

  
    def id_valid	  
      if user_id and ! User.by_id(user_id) 
        errors.add( :user_id, "has to be valid, #{user_id} is not")
      end
    end
    
    def self.new_ip_and_client( user, ip, client )
      u_s = self.new( user: user, ip: ip, client: client )
	  u_s.remember
      u_s.save!
      return u_s
    end
    
    def self.recover( session_id, remember_token )
      
      if !session_id
        return nil
      end

      u = self.where( id: session_id )
      usession = u[0] ? u[0] : nil   
      if usession and usession.remember_check( remember_token )
        return usession
      else
        return nil
      end
            
    end      

	def set_cookies(cookies)
	  cookies.encrypted[:user_session_id] = { value: self.id, expires: 1.month.from_now.utc }
	  cookies.encrypted[:remember_token] = { value: self.remember_token, expires: 1.month.from_now.utc }	
    end  
    def self.clear_cookies(cookies)
	  cookies.delete :user_session_id
	  cookies.delete :remember_token
    end
  
    def remember
      self.remember_token = SecureRandom.urlsafe_base64
	  cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      rd = BCrypt::Password.create(remember_token, cost: cost)	
      self.remember_digest = rd
    end	    
	
	def remember_check( remember_token )
	  BCrypt::Password.new(self.remember_digest).is_password?(remember_token)
	end
   
  end

