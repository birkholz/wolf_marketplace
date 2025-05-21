RSpec.describe AuthenticationService do
  let(:service) { described_class.new }

  context 'when the JWT is malformed' do
    let(:malformed_token) { 'malformed.jwt.token' }

    it 'returns nil' do
      expect(AuthenticationService.decode_token(malformed_token)).to be_nil
    end
  end
end
