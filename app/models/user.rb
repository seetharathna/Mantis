class User < ActiveRecord::Base
  acts_as_authentic do |c|


  
    #c.validate_login_field = false
    #c.validate_crypted_password = false
  end

  has_and_belongs_to_many :roles


def has_role?(role)
    list ||= self.roles.collect(&:name)
    list.include?(role.to_s) || list.include?('admin')
end

def before_connect(facebook_session)
    self.name = facebook_session.user.name
end


 # START:USER_FOR
    def self.for(facebook_id,facebook_session = nil)
    user = User.find_or_create_by_facebook_id(facebook_id)
    unless facebook_session.nil?
      user.store_session(facebook_session.session_key) 
      #user.store_first_name_and_last_name(facebook_session.first_name,facebook_session.last_name)
    end
     return user
    end
  # END:USER_FOR
  
  # START:STORE_SESSION
  def store_session(session_key)
    if self.session_key != session_key
      self.update_attribute(:session_key,session_key) 
    end
  end 
 # END:STORE_SESSION

  def store_first_name_and_last_name(first_name,last_name)
     self.update_attribute(:first_name,:last_name,first_name,last_name) 
  end 
  	
  def facebook_session
  
    @facebook_session ||=  # <label id="code.conditional-assign" />
      returning Facebooker::Session.create do |session| # <label id="code.returning" />
        session.secure_with!(session_key,facebook_id,1.day.from_now) # <label id="code.secure-with" />
        Facebooker::Session.current = session
    end
  end


end
