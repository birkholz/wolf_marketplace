class SessionService
  def self.authenticate_user(email, password, user_class)
    user = user_class.find_by(email: email)

    if user&.authenticate(password)
      { success: true, token: AuthenticationService.generate_token_for(user) }
    else
      { success: false, error: "Invalid email or password" }
    end
  end
end
