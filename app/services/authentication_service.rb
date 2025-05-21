class AuthenticationService
  def self.generate_token_for(user)
    payload = { sub: user.id }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end

  def self.decode_token(token)
    return nil unless token

    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
      decoded_token[0]['sub']
    rescue JWT::DecodeError
      nil
    end
  end

  def self.extract_token_from_header(auth_header)
    return nil unless auth_header

    auth_header.split(' ').last
  end
end
