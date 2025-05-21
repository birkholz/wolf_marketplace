require 'rails_helper'

RSpec.describe JobApplication, type: :model do
  describe 'associations' do
    it { should belong_to(:job_seeker) }
    it { should belong_to(:opportunity) }
  end
end
