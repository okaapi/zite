
  class UserAction < ZiteActiveRecord
    PARAMS_CLIP = 128
    belongs_to :user_session
    validates :user_session_id, :presence => true  
    validate :user_session_id_valid

    def self.add_action( session_id, controller, action, parameters )
    
      user_action = self.new( user_session_id: session_id )  
      user_action.controller = controller
      user_action.action = action
   
      user_action.params = ""
      parameters.each do |k,v|           
        case k
        when "action", "controller", "kennwort", "confirmation", "authenticity_token", "utf8", "captcha"
          ;
        else
          user_action.params += "#{k}: #{v.to_s}; "
        end
      end
      user_action.params = user_action.params[0..PARAMS_CLIP]
      
      user_action.save

      return user_action
      
    end    
      
    private
    
    def user_session_id_valid
      if ! UserSession.where( id: user_session_id ).take
        errors.add( :user_session_id, "has to be valid" )
      end
    end
    
  end


