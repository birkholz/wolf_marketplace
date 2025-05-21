require 'rails_helper'

RSpec.describe Opportunity, type: :model do
  describe 'associations' do
    it { should belong_to(:client) }
    it { should have_many(:job_applications) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:salary) }
  end
end
