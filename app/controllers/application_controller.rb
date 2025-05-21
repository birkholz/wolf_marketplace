class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_client
  helper_method :client_signed_in?
  helper_method :current_job_seeker
  helper_method :job_seeker_signed_in?

  private

  def current_client
    return @current_client if defined?(@current_client)
    token = AuthenticationService.extract_token_from_header(request.headers["Authorization"])
    user_id = AuthenticationService.decode_token(token)
    @current_client = user_id && Client.find_by(id: user_id)
  end

  def client_signed_in?
    current_client.present?
  end

  def authenticate_client!
    unless client_signed_in?
      render json: { error: "Authentication required" }, status: :unauthorized
    end
  end

  def current_job_seeker
    return @current_job_seeker if defined?(@current_job_seeker)
    token = AuthenticationService.extract_token_from_header(request.headers["Authorization"])
    user_id = AuthenticationService.decode_token(token)
    @current_job_seeker = user_id && JobSeeker.find_by(id: user_id)
  end

  def job_seeker_signed_in?
    current_job_seeker.present?
  end

  def authenticate_job_seeker!
    unless job_seeker_signed_in?
      render json: { error: "Authentication required" }, status: :unauthorized
    end
  end
end
