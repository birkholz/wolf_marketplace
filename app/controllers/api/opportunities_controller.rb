module Api
  class OpportunitiesController < ApplicationController
    before_action :authenticate_client!, only: [:create]
    before_action :authenticate_job_seeker!, only: [:apply]
    before_action :set_opportunity, only: [:apply]

    def index
      @opportunities = opportunity_service.search_opportunities

      render json: {
        opportunities: @opportunities.as_json(include: { client: { only: [:id, :name] } }),
        meta: {
          current_page: @opportunities.current_page,
          total_pages: @opportunities.total_pages,
          total_count: @opportunities.total_count
        }
      }
    end

    def create
      result = opportunity_service.create_opportunity(current_client, opportunity_params)

      if result[:success]
        render json: result[:opportunity], status: :created
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    end

    def apply
      result = opportunity_service.apply_for_opportunity(@opportunity, current_job_seeker)

      if result[:success]
        render json: result[:application], status: :created
      else
        render json: { error: result[:error] || result[:errors] }, status: :unprocessable_entity
      end
    end

    private

    def set_opportunity
      @opportunity = Opportunity.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Opportunity not found" }, status: :not_found
    end

    def opportunity_params
      params.require(:opportunity).permit(:title, :description, :salary)
    end

    def opportunity_service
      @opportunity_service ||= OpportunityService.new(params)
    end
  end
end
