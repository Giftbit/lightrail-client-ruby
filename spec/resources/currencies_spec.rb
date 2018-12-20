require "spec_helper"
require "securerandom"
require "dotenv"
Dotenv.load

RSpec.describe Lightrail::Currencies do
  subject(:factory) {Lightrail::Currencies}

  describe "Currency Tests" do
    Lightrail.api_key = ENV["LIGHTRAIL_TEST_API_KEY"]

    code = SecureRandom.alphanumeric.to_s

    it "can create a currency" do
      create = factory.create({
                                  code: code,
                                  name: "Fake Currency To Delete",
                                  symbol: "$",
                                  decimalPlaces: 0
                              })
      expect(create.body["code"]).to eq(code)
      expect(create.body["name"]).to eq("Fake Currency To Delete")
      expect(create.body["symbol"]).to eq("$")
      expect(create.body["decimalPlaces"]).to eq(0)
    end

    it "can get a currency" do
      create = factory.get(code)
      expect(create.body["code"]).to eq(code)
      expect(create.body["name"]).to eq("Fake Currency To Delete")
      expect(create.body["symbol"]).to eq("$")
      expect(create.body["decimalPlaces"]).to eq(0)
    end

    it "can update a currency" do
      update = factory.update(code, {name: "New Fake Name To Delete"})
      expect(update.status).to eq(200)
      expect(update.body["name"]).to eq("New Fake Name To Delete")
    end

    it "can list currencies" do
      list = factory.list({code: code})
      expect(list.status).to eq(200)

      # make sure the objects that come back look like currencies
      expect(list.body[0].key?("code")).to be_truthy
      expect(list.body[0].key?("name")).to be_truthy
      expect(list.body[0].key?("symbol")).to be_truthy
      expect(list.body[0].key?("decimalPlaces")).to be_truthy
    end

    it "can delete a currency" do
      delete = factory.delete(code)
      expect(delete.status).to eq(200)

      get = factory.get(code)
      expect(get.status).to eq(404)
    end

    # error handling
    it "can't get a currency that doesn't exist" do
      create = factory.get("NO_SUCH_CURRENCY")
      expect(create.status).to eq(404)
    end

    describe "calling get with invalid id arguments" do
      it "can't get Currency with id = {}" do
        expect {factory.get({})}.to raise_error do |error|
          expect(error).to be_a(Lightrail::BadParameterError)
          expect(error.message).to eq("Argument id must be set.")
        end
      end

      it "can't get Currency with id = nil" do
        expect {factory.get(nil)}.to raise_error do |error|
          expect(error).to be_a(Lightrail::BadParameterError)
          expect(error.message).to eq("Argument id must be set.")
        end
      end
    end

    it "can't update a currency that doesn't exist - throws exception" do
      expect {factory.update("NO_SUCH_CURRENCY", {name: "New Fake Name To Delete"})}.to raise_error do |error|
        expect(error).to be_a(Lightrail::LightrailError)
        expect(error.status).to eq(404)
      end
    end

    it "can't delete with non-existent id - throws exception" do
      expect {factory.delete("NON_EXISTENT_ID")}.to raise_error do |error|
        expect(error).to be_a(Lightrail::LightrailError)
        expect(error.status).to eq(404)
      end
    end

    # setup USD currency
    it "create USD currency if it doesn't already exist" do
      usd_currency = factory.get("USD")
      if usd_currency.status == 404
        create = factory.create({
                                    code: "USD",
                                    name: "US Dollars",
                                    symbol: "$",
                                    decimalPlaces: 2
                                })
        expect(create.status).to eq(201)
      end
    end
  end
end
