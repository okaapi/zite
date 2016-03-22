
  class UserSession < ZiteActiveRecord
    
    SESSION_TIMEOUT = 60 * 60 * 4 # 4 hours
    attr_accessor :idle
    belongs_to :user
    validate :id_valid
    
    has_many :user_actions, dependent: :destroy  
  
    def idle
      t = ( Time.now - ( updated_at or Time.now ) )
      return t
    end 
    
    private
  
    def id_valid
      if user_id
        begin
          User.find(user_id)
        rescue
          errors.add( :user_id, "has to be valid")
          false
        end
      end
    end
    
    def self.new_ip_and_client( user, ip, client )
      u_s = self.new( user: user, ip: ip, client: client )
      u_s.save!
      return u_s
    end
    
    def self.recover( session_id )
      
      return if !session_id

      u = self.where( id: session_id )
      usession = u[0] ? u[0] : nil       
      if usession and usession.idle < SESSION_TIMEOUT
        usession.id_will_change!  # make random attribute dirty
        usession.save             # to update updated_at
        return usession         
      else
        return nil
      end
            
    end             
   
  end

