require "spec_helper"

RSpec.describe Lightrail::ShopperTokenFactory do
  subject(:factory) {Lightrail::ShopperTokenFactory}

  let(:example_api_key) {'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJnIjp7Imd1aSI6Imdvb2V5IiwiZ21pIjoiZ2VybWllIiwidG1pIjoidGVlbWllIn19.Xb8x158QIV2ukGuQ3L5u4KPrL8MC-BToabnzKMQy7oc'}
  let(:example_shared_secret) {'secret'}
  let(:example_contact_id) {'this-is-a-contact-id'}

  describe ".generate" do
    before(:each) do
      allow(Lightrail).to receive(:api_key).and_return(example_api_key)
      allow(Lightrail).to receive(:shared_secret).and_return(example_shared_secret)
    end

    it "generates a JWT with the supplied contact_id" do
      token = factory.generate(example_contact_id)
      decoded = JWT.decode(token, example_shared_secret, true, {algorithm: 'HS256'})
      expect(decoded[0]['g']['coi']).to eq(example_contact_id)
    end

    it "generates a JWT with metadata" do
      token = factory.generate(example_contact_id, {metadata: {foo: "bar"}, validity_in_seconds: 666})
      decoded = JWT.decode(token, example_shared_secret, true, {algorithm: 'HS256'})

      expect(decoded[0]['g']['coi']).to eq(example_contact_id)
      expect(decoded[0]['g']['gui']).to eq('gooey')
      expect(decoded[0]['g']['gmi']).to eq('germie')
      expect(decoded[0]['g']['tmi']).to eq('teemie')
      puts decoded[0]
      expect(decoded[0]).to have_key('metadata')
      expect(decoded[0]['metadata']).to have_key('foo')
      expect(decoded[0]['metadata']['foo']).to eq('bar')
      expect(decoded[0]['exp']).to eq(decoded[0]['iat'] + 666)
    end

    it "correctly applies the specified validity period" do
      token = factory.generate(example_contact_id, 12)
      decoded = JWT.decode(token, example_shared_secret, true, {algorithm: 'HS256'})

      expect(decoded[0]['exp']).to eq(decoded[0]['iat'] + 12)
    end

    it "includes 'iat'" do
      token = factory.generate(example_contact_id)
      decoded = JWT.decode(token, example_shared_secret, true, {algorithm: 'HS256'})
      expect(decoded[0]['iat']).to be_a(Integer)
    end

    it "includes 'iss: MERCHANT'" do
      token = factory.generate(example_contact_id)
      decoded = JWT.decode(token, example_shared_secret, true, {algorithm: 'HS256'})
      expect(decoded[0]['iss']).to eq("MERCHANT")
    end
  end
end
