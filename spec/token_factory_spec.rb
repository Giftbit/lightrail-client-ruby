require "spec_helper"

RSpec.describe Lightrail::TokenFactory do
  subject(:factory) {Lightrail::TokenFactory}

  let(:example_api_key) {'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJnIjp7Imd1aSI6InVzZXItZWI2NDYwYWZhNWIwNDQxYmFjYmI0MTI5MGZhZjAxNDctVEVTVCIsImdtaSI6InVzZXItZWI2NDYwYWZhNWIwNDQxYmFjYmI0MTI5MGZhZjAxNDctVEVTVCJ9LCJpYXQiOiIyMDE3LTA3LTA1VDIxOjM4OjQ5LjEzMSswMDAwIiwibmFtZSI6IkpvaG4gRG9lIn0.bhMlwrU4ZoMNRQB47-Twx2Eev7LpBG4d4Sc6Gmxq0oo'}
  let(:example_shared_secret) {'secret'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}


  describe ".generate" do
    before(:each) do
      allow(Lightrail).to receive(:api_key).and_return(example_api_key)
      allow(Lightrail).to receive(:shared_secret).and_return(example_shared_secret)
    end

    it "generates a JWT with the supplied shopper_id" do
      token = factory.generate(example_shopper_id)
      decoded = JWT.decode(token, example_shared_secret, true, {algorithm: 'HS256'})

      expect(decoded[0][0]['data']['shopperId']).to eq(example_shopper_id)
    end

    it "correctly applies the specified validity period" do
      token = factory.generate(example_shopper_id, 12)
      decoded = JWT.decode(token, example_shared_secret, true, {algorithm: 'HS256'})

      expect(decoded[0][0]['data']['exp']).to eq(decoded[0][0]['data']['iat'] + 12)
    end
  end
end