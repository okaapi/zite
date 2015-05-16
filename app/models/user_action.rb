
  class UserAction < ActiveRecord::Base
    PARAMS_CLIP = 63
    belongs_to :user_session
    validates :user_session_id, :presence => true  
    validate :user_session_id_valid

    def self.add_action( session_id, controller, action, p )
    
      user_action = self.new( user_session_id: session_id )  
      user_action.controller = controller
      user_action.action = action
      parameters = p.clone
      parameters.delete(:action)
      parameters.delete(:controller)      
      parameters.delete(:password) if parameters[:password]      
      parameters[:filename] = p[:file].original_filename if p[:file]
      user_action.params = parameters.to_s[0..PARAMS_CLIP]   
      user_action.save
    end    
      
    private
    
    def user_session_id_valid
      begin
        UserSession.find(user_session_id)
      rescue
        errors.add( :user_session_id, "has to be valid")
      end
    end
    
  end
