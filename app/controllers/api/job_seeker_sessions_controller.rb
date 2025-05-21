module Api
  class JobSeekerSessionsController < ApplicationController
    def create
      result = SessionService.authenticate_user(params[:email], params[:password], JobSeeker)

      if result[:success]
        render json: { token: result[:token] }, status: :ok
      else
        render json: { error: result[:error] }, status: :unauthorized
      end
    end

    def destroy
      session[:job_seeker_id] = nil
      render json: { message: "Logged out successfully" }, status: :ok
    end
  end
end
