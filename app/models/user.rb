class User < ActiveRecord::Base
  
  validates_presence_of :username
  validates_presence_of :password, :if => :password_required?
  validates_uniqueness_of :username, :case_sensitive => false
  validates_confirmation_of :password, :unless => Proc.new{|user|user.password.blank?}
  
  attr_accessor :password, :password_confirmation
  attr_protected :password_hash, :password_type, :salt
  
  before_destroy :dont_destroy_admin
  
  ###
  # Class Methods
  
  # Authenticate a user using a username/email and password
  def self.authenticate(username, pw)
    requested_person = User.find_by_username(username.downcase)
    if requested_person
      return requested_person if requested_person.password_is?(pw.downcase)
    end
    return false
  end
  
  ###
  # Attribute Accessors
  
  def name
    self.first_name + ' ' + self.last_name
  end
  
  def login_token
    Digest::SHA256.hexdigest(self.username + self.password_hash + self.salt)
  end
  
  ###
  # Attribute Setters

  def username=(new_username)
    write_attribute('username', new_username.strip.downcase) if new_username
  end
  
  def email=(new_email)
    write_attribute('email', new_email.downcase) if new_email
  end
  
  def password=(new_pass)
    if !new_pass.blank?
      @password = new_pass.downcase
      salt = [Array.new(6){rand(256).chr}.join].pack("m")[0..7]; # 2^48 combos
      # password_salt and password_sha1 are DB-backed AR attributes
      # User has a password type with the encryption method for future evolution
      self.password_type = 'sha256'
      self.salt, self.password_hash = salt, Digest::SHA256.hexdigest(new_pass + salt)
    end
  end
  
  ###
  # Instance Methods
  
  def login!(session)
    session[:user_id] = id
  end
  
  def logout!(session)
    session[:user_id] = nil
  end
  
  # Check if a user's password is correct 
  def password_is?(pw)
    case self.password_type 
      when 'sha256' then return Digest::SHA256.hexdigest(pw.downcase + self.salt) == self.password_hash
      else raise _("Invalid Password Format")
    end
  end
  
  def profile_complete?
    self.email && self.phone_number
  end
  
  protected

    #:nodoc:
    def password_required?
      # Is the password required? Yes in the following cases
      #  Hashed password is empty (no password defined yet)
      #  The password field has been filled in
      password_hash.nil? || !password.blank?
    end

    ###
    # Callbacks

    def dont_destroy_admin
      return false if self.is_admin?
    end
  
end
