require "spec_helper"
require "securerandom"
require "dotenv"
Dotenv.load

RSpec.describe Lightrail::Values do
  subject(:factory) {Lightrail::Values}

  describe "Value Tests" do
    Lightrail.api_key = ENV["LIGHTRAIL_TEST_API_KEY"]

    value_id = SecureRandom.uuid
    full_code = SecureRandom.alphanumeric.to_s
    last4 = full_code.split(//).last(4).join("").to_s
    it "can create a Value" do
      response = Lightrail::Values.create(
          {
              id: value_id,
              currency: "USD",
              balance: 10,
              code: full_code
          })
      expect(response.body["id"]).to eq(value_id)
      expect(response.body["currency"]).to eq("USD")
      expect(response.body["balance"]).to eq(10)
      expect(response.body["code"]).to eq("…#{last4}")

      # check extra response properties are null
      expect(response.links).to be_nil
      expect(response.limit).to be_nil
      expect(response.max_limit).to be_nil
    end

    it "can create a Value passing in string hash keys" do
      response = Lightrail::Values.create(
          {
              "id": SecureRandom.uuid,
              "currency": "USD",
              "balance": 15,
          })
      expect(response.body["currency"]).to eq("USD")
      expect(response.body["balance"]).to eq(15)
    end

    it "can't create a Value without an id - test basic error handling" do
      expect {Lightrail::Values.create({currency: "USD"})
      }.to raise_error do |error|
        expect(error).to be_a(Lightrail::LightrailError)
        expect(error.status).to eq(422)
        expect(error.message).to_not be_nil
      end
    end

    it "can get Value" do
      response = Lightrail::Values.get(value_id, {
          id: value_id,
          currency: "USD",
          balance: 10
      })
      expect(response.body["id"]).to eq(value_id)
      expect(response.body["currency"]).to eq("USD")
      expect(response.body["balance"]).to eq(10)
      expect(response.body["code"]).to eq("…#{last4}")
    end

    it "can get Value and view fullcode" do
      response = Lightrail::Values.get(value_id, {showCode: true})
      expect(response.body["id"]).to eq(value_id)
      expect(response.body["currency"]).to eq("USD")
      expect(response.body["balance"]).to eq(10)
      expect(response.body["code"]).to eq(full_code)
    end

    it "can list Values" do
      response = Lightrail::Values.list
      puts "response.links"
      puts response.links
      expect(response.links).to_not be_nil
        # expect(response.body[0]["currency"]).to eq("USD")
        # expect(response.body[0]["balance"]).to eq(10)
        # expect(response.body[0]["code"]).to eq(full_code)
    end

    # TODO - hash keys can be string or symbols. it would be nice if we can accept both. Do a test making sure we accept string parameters.
  end
end
