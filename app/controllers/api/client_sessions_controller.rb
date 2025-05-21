module Api
  class ClientSessionsController < ApplicationController
    def create
      result = SessionService.authenticate_user(params[:email], params[:password], Client)

      if result[:success]
        render json: { token: result[:token] }, status: :ok
      else
        render json: { error: result[:error] }, status: :unauthorized
      end
    end

    def destroy
      session[:client_id] = nil
      render json: { message: "Logged out successfully" }, status: :ok
    end
  end
end
