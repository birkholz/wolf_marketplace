require 'rails_helper'

RSpec.describe OpportunityService do
  let(:client) { create(:client) }
  let(:job_seeker) { create(:job_seeker) }
  let(:service) { described_class.new(params) }
  let(:params) { {} }

  describe "#search_opportunities" do
    let!(:opportunities) { create_list(:opportunity, 3, client: client) }
    let!(:unique_opportunity) { create(:opportunity, title: "Unique Title", client: client) }

    around(:each, :caching) do |example|
      original_store = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      example.run
      Rails.cache = original_store
    end

    context "without search params" do
      it "returns all opportunities" do
        result = service.search_opportunities
        expect(result.length).to eq(4)
      end
    end

    context "with search query" do
      context "searching by title" do
        let(:params) { { query: "Unique" } }

        it "returns matching opportunities" do
          result = service.search_opportunities
          expect(result.length).to eq(1)
          expect(result.first.title).to eq("Unique Title")
        end
      end

      context "searching by client name" do
        let!(:unique_client) { create(:client, name: "Unique Company") }
        let!(:client_opportunity) { create(:opportunity, client: unique_client) }

        context "with exact client name" do
          let(:params) { { query: "Unique Company" } }

          it "returns opportunities from matching client" do
            result = service.search_opportunities
            expect(result.length).to eq(1)
            expect(result.first.client.name).to eq("Unique Company")
          end
        end

        context "with partial client name" do
          let(:params) { { query: "Unique" } }

          it "returns opportunities from clients with matching name" do
            result = service.search_opportunities
            expect(result.length).to eq(2) # One from unique_opportunity and one from client_opportunity
            expect(result.map(&:client).map(&:name)).to include("Unique Company")
          end
        end
      end
    end

    context "with pagination" do
      let(:params) { { page: 1, per_page: 2 } }

      it "returns paginated results" do
        result = service.search_opportunities
        expect(result.length).to eq(2)
        expect(result.total_pages).to eq(2)
      end
    end

    context "with caching", :caching do
      it "caches the results" do
        expect(Rails.cache).to receive(:fetch).and_call_original
        service.search_opportunities
      end

      it "uses correct cache key" do
        params = { query: "test", page: 2, per_page: 5 }
        service = described_class.new(params)
        expect(Rails.cache).to receive(:fetch).with(
          "opportunities/test/page_2/per_5",
          expires_in: 1.hour
        ).and_call_original
        service.search_opportunities
      end
    end

    context 'when caching is disabled via configuration' do
      around(:each) do |example|
        original_enable_cache = Rails.configuration.enable_cache
        Rails.configuration.enable_cache = false
        example.run
        Rails.configuration.enable_cache = original_enable_cache
      end

      it 'returns all opportunities without caching' do
        result = service.search_opportunities
        expect(result.length).to eq(4)
      end
    end
  end

  describe "#create_opportunity" do
    let(:opportunity_params) do
      {
        title: "Registered Nurse",
        description: "Looking for an experienced registered nurse",
        salary: 200000
      }
    end

    context "with valid params" do
      it "creates a new opportunity" do
        result = service.create_opportunity(client, opportunity_params)
        expect(result[:success]).to be true
        expect(result[:opportunity]).to be_persisted
        expect(result[:opportunity].title).to eq("Registered Nurse")
      end

      it "invalidates the cache" do
        expect(Rails.cache).to receive(:delete_matched).with("opportunities/*")
        service.create_opportunity(client, opportunity_params)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { title: "" } }

      it "returns error messages" do
        result = service.create_opportunity(client, invalid_params)
        expect(result[:success]).to be false
        expect(result[:errors]).to be_present
      end
    end
  end

  describe "#apply_for_opportunity" do
    let(:opportunity) { create(:opportunity, client: client) }

    context "when job seeker hasn't applied" do
      it "creates a new application" do
        result = service.apply_for_opportunity(opportunity, job_seeker)
        expect(result[:success]).to be true
        expect(result[:application]).to be_persisted
        expect(result[:application].job_seeker).to eq(job_seeker)
      end

      it "enqueues notification job" do
        expect {
          service.apply_for_opportunity(opportunity, job_seeker)
        }.to have_enqueued_job(JobApplicationNotificationJob).with(kind_of(Integer))
      end
    end

    context "when job seeker has already applied" do
      before do
        create(:job_application, opportunity: opportunity, job_seeker: job_seeker)
      end

      it "returns error message" do
        result = service.apply_for_opportunity(opportunity, job_seeker)
        expect(result[:success]).to be false
        expect(result[:error]).to eq('You have already applied for this opportunity')
      end
    end

    context "when the application fails to save" do
      before do
        allow_any_instance_of(JobApplication).to receive(:save).and_return(false)
        allow_any_instance_of(JobApplication).to receive(:errors).and_return(double(full_messages: ['Error message']))
      end

      it "returns error message" do
        result = service.apply_for_opportunity(opportunity, job_seeker)
        expect(result[:success]).to be false
        expect(result[:errors]).to eq(['Error message'])
      end
    end
  end
end
