class OpportunityService
  def initialize(params = {})
    @params = params
  end

  def search_opportunities
    cache_key = generate_cache_key

    if Rails.configuration.enable_cache
      cached_data = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        opportunities = base_query
        opportunities = apply_search(opportunities) if @params[:query].present?
        paginated = apply_pagination(opportunities)
        { ids: paginated.pluck(:id), total_count: paginated.total_count }
      end
      opportunities = Opportunity.includes(:client).where(id: cached_data[:ids])
      # Preserve pagination order
      opportunities = opportunities.index_by(&:id).values_at(*cached_data[:ids])
      Kaminari.paginate_array(opportunities, total_count: cached_data[:total_count]).page(@params[:page] || 1).per(@params[:per_page] || 10)
    else
      opportunities = base_query
      opportunities = apply_search(opportunities) if @params[:query].present?
      apply_pagination(opportunities)
    end
  end

  def create_opportunity(client, opportunity_params)
    opportunity = client.opportunities.build(opportunity_params)

    if opportunity.save
      invalidate_cache
      { success: true, opportunity: opportunity }
    else
      { success: false, errors: opportunity.errors.full_messages }
    end
  end

  def apply_for_opportunity(opportunity, job_seeker)
    if opportunity.job_applications.exists?(job_seeker: job_seeker)
      { success: false, error: "You have already applied for this opportunity" }
    else
      application = opportunity.job_applications.build(job_seeker: job_seeker)

      if application.save
        NotificationService.notify_new_application(application)
        { success: true, application: application }
      else
        { success: false, errors: application.errors.full_messages }
      end
    end
  end

  private

  def base_query
    Opportunity.includes(:client)
  end

  def apply_search(opportunities)
    opportunities.joins(:client)
      .where("opportunities.title ILIKE :q OR opportunities.description ILIKE :q OR clients.name ILIKE :q", q: "%#{@params[:query]}%")
  end

  def apply_pagination(opportunities)
    page = (@params[:page] || 1).to_i
    per_page = (@params[:per_page] || 10).to_i
    opportunities.page(page).per(per_page)
  end

  def generate_cache_key
    query = @params[:query].presence || "all"
    page = @params[:page] || 1
    per_page = @params[:per_page] || 10

    "opportunities/#{query}/page_#{page}/per_#{per_page}"
  end

  def invalidate_cache
    Rails.cache.delete_matched("opportunities/*")
  end
end
