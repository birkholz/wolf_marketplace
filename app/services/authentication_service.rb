class AuthenticationService
  SECRET_KEY = Rails.application.secret_key_base

  def self.generate_token_for(user)
    JWT.encode({ sub: user.jwt_subject, exp: 24.hours.from_now.to_i }, SECRET_KEY, "HS256")
  end

  def self.decode_token(token)
    return nil unless token
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
    decoded[0]["sub"]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def self.extract_token_from_header(auth_header)
    return nil unless auth_header&.start_with?("Bearer ")
    auth_header.split(" ").last
  end
end
