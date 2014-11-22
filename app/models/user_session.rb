
  class UserSession < ActiveRecord::Base
    
    SESSION_TIMEOUT = 120
    attr_accessor :idle
    belongs_to :user
    #validates :user_id, :presence => true
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
      
      begin
        session = self.find( session_id )
        if session.idle < SESSION_TIMEOUT
          session.id_will_change!  # make random attribute dirty
          session.save             # to update updated_at
          return session         
        else
          return nil
        end
      rescue ActiveRecord::RecordNotFound
        return nil
      end
            
    end             
   
  end

