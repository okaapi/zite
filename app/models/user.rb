require 'securerandom'

  class User < ZiteActiveRecord
  
    validates :username, presence: true, uniqueness: { scope: :site }
    validates :email, presence: true, uniqueness: { scope: :site }, email: true   
    validates :password, length: { minimum: 3 }
    has_secure_password
    has_many :user_sessions, dependent: :destroy
    
    def self.find_by_email_or_alternate( email )
      user = User.find_by_email( email )
      if !user 
        user = User.find_by_alternate_email( email )
      end  
      return user
    end
    
    def self.find_by_email_or_username( claim )
      User.find_by_email( claim ) || User.find_by_username( claim )
    end
  
    def self.new_unconfirmed( email, username )
      user = User.new( email: email, username: username )
      user.password = user.password_confirmation = SecureRandom.urlsafe_base64(8)
      user.token = SecureRandom.urlsafe_base64(16)
      user.active = 'unconfirmed'    
      user
    end
  
    def suspend_and_save
      self.password = self.password_confirmation = SecureRandom.urlsafe_base64(8)
      self.token = SecureRandom.urlsafe_base64(16)
      self.active = 'suspended'
      self.save
    end
       
    def confirmed?
      ( active == 'confirmed' )
    end
    
    def admin?
      ( role == 'admin')
    end

    def change_role( new_role )
      if ['admin','user','editor'].include? new_role
        self.update_attribute( :role, new_role )
      end
    end
    
    def confirm
      self.update_attribute( :active, confirmed )
    end    
    
  end
  
