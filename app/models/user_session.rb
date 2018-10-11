
  class UserSession < ZiteActiveRecord
    
    SESSION_TIMEOUT = 60*15 # seconds = 15 min
    attr_accessor :idle
    belongs_to :user
    validate :id_valid
    
    has_many :user_actions, dependent: :destroy  
  
    def idle
      t = ( Time.now - ( updated_at or Time.now ) )
      return t
    end 
	
	def _user	
	  # overriding this in because it fails with scope
	  User.by_id( user_id )
	end
    
    private
  
    def id_valid	  
      if user_id and ! User.by_id(user_id) 
        errors.add( :user_id, "has to be valid, #{user_id} is not")
      end
    end
    
    def self.new_ip_and_client( user, ip, client )
      u_s = self.new( user: user, ip: ip, client: client )
      u_s.save!
      return u_s
    end
    
    def self.recover( session_id )
      
      if !session_id
        return nil, 0
      end

      u = self.where( id: session_id )
      usession = u[0] ? u[0] : nil   
      if usession 
        idle_time = usession.idle
        if idle_time < SESSION_TIMEOUT
          #usession.id_will_change!  # make random attribute dirty (id_will_change is not a db column)
          #usession.save             # to update updated_at
          return usession, idle_time
        else 
          return nil, 0
        end
      else
        return nil, 0
      end
            
    end             
   
  end

