require 'rails_helper'

RSpec.describe "Opportunities API", type: :request do
  let(:client) { create(:client) }
  let(:job_seeker) { create(:job_seeker) }
  let(:client_token) { generate_token_for(client) }
  let(:job_seeker_token) { generate_token_for(job_seeker) }
  let(:valid_opportunity_params) do
    {
      opportunity: {
        title: "Registered Nurse",
        description: "Looking for an experienced registered nurse",
        salary: 200000
      }
    }
  end

  describe "GET /api/opportunities" do
    let!(:opportunities) { create_list(:opportunity, 3, client: client) }

    context "without authentication" do
      it "returns a list of opportunities" do
        get "/api/opportunities"

        expect(response).to have_http_status(:ok)
        expect(json_response["opportunities"].length).to eq(3)
        expect(json_response["meta"]).to include(
          "current_page" => 1,
          "total_pages" => 1,
          "total_count" => 3
        )
      end

      it "supports pagination" do
        get "/api/opportunities", params: { page: 1, per_page: 2 }

        expect(response).to have_http_status(:ok)
        expect(json_response["opportunities"].length).to eq(2)
        expect(json_response["meta"]["total_pages"]).to eq(2)
      end

      it "supports search by title" do
        create(:opportunity, title: "Unique Title", client: client)

        get "/api/opportunities", params: { query: "Unique" }

        expect(response).to have_http_status(:ok)
        expect(json_response["opportunities"].length).to eq(1)
        expect(json_response["opportunities"].first["title"]).to eq("Unique Title")
      end

      it "supports search by client name" do
        unique_client = create(:client, name: "Unique Company")
        create(:opportunity, client: unique_client)
        create(:opportunity, client: client) # This one should not be included

        get "/api/opportunities", params: { query: "Unique Company" }

        expect(response).to have_http_status(:ok)
        expect(json_response["opportunities"].length).to eq(1)
        expect(json_response["opportunities"].first["client"]["name"]).to eq("Unique Company")
      end

      it "supports search by partial client name" do
        unique_client = create(:client, name: "Unique Company")
        create(:opportunity, client: unique_client)
        create(:opportunity, client: client) # This one should not be included

        get "/api/opportunities", params: { query: "Unique" }

        expect(response).to have_http_status(:ok)
        expect(json_response["opportunities"].length).to eq(1)
        expect(json_response["opportunities"].first["client"]["name"]).to eq("Unique Company")
      end
    end
  end

  describe "POST /api/opportunities" do
    context "with client authentication" do
      it "creates a new opportunity" do
        expect {
          post "/api/opportunities",
               params: valid_opportunity_params,
               headers: { "Authorization" => "Bearer #{client_token}" }
        }.to change(Opportunity, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response["title"]).to eq("Registered Nurse")
        expect(json_response["client_id"]).to eq(client.id)
      end

      it "returns validation errors for invalid params" do
        post "/api/opportunities",
             params: { opportunity: { title: "" } },
             headers: { "Authorization" => "Bearer #{client_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["errors"]).to be_present
      end
    end

    context "without authentication" do
      it "returns unauthorized status" do
        post "/api/opportunities", params: valid_opportunity_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/opportunities/:id/apply" do
    let(:opportunity) { create(:opportunity, client: client) }

    context "with job seeker authentication" do
      it "creates a job application" do
        expect {
          post "/api/opportunities/#{opportunity.id}/apply",
               headers: { "Authorization" => "Bearer #{job_seeker_token}" }
        }.to change(JobApplication, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response["job_seeker_id"]).to eq(job_seeker.id)
        expect(json_response["opportunity_id"]).to eq(opportunity.id)
      end

      it "prevents duplicate applications" do
        create(:job_application, opportunity: opportunity, job_seeker: job_seeker)

        post "/api/opportunities/#{opportunity.id}/apply",
             headers: { "Authorization" => "Bearer #{job_seeker_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to eq("You have already applied for this opportunity")
      end
    end

    context "without authentication" do
      it "returns unauthorized status" do
        post "/api/opportunities/#{opportunity.id}/apply"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid opportunity id" do
      it "returns not found status" do
        post "/api/opportunities/999/apply",
             headers: { "Authorization" => "Bearer #{job_seeker_token}" }

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("Opportunity not found")
      end
    end
  end
end
