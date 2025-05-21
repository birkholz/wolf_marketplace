module RequestSpecHelper
  def json_response
    JSON.parse(response.body)
  end

  def generate_token_for(user)
    AuthenticationService.generate_token_for(user)
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end
