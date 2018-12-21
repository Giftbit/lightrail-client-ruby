require "spec_helper"
require "securerandom"
require "dotenv"
Dotenv.load

RSpec.describe Lightrail::Values do
  subject(:values) {Lightrail::Values}

  describe "Value Tests" do
    Lightrail.api_key = ENV["LIGHTRAIL_TEST_API_KEY"]

    value_id = SecureRandom.uuid
    full_code = SecureRandom.alphanumeric.to_s
    last4 = Lightrail::TestHelper.get_last_four(full_code)
    it "can create a Value" do
      create = values.create(
          {
              id: value_id,
              currency: "USD",
              balance: 10,
              code: full_code
          })
      expect(create.body["id"]).to eq(value_id)
      expect(create.body["currency"]).to eq("USD")
      expect(create.body["balance"]).to eq(10)
      expect(create.body["code"]).to eq(last4)

      # check extra response properties are null
      expect(create.links).to be_nil
      expect(create.limit).to be_nil
      expect(create.max_limit).to be_nil
    end

    it "can get Value" do
      get = values.get(value_id)
      expect(get.body["id"]).to eq(value_id)
      expect(get.body["currency"]).to eq("USD")
      expect(get.body["balance"]).to eq(10)
      expect(get.body["code"]).to eq(last4)
    end


    it "can get Value and view fullcode" do
      get = values.get(value_id, {showCode: true})
      expect(get.body["id"]).to eq(value_id)
      expect(get.body["currency"]).to eq("USD")
      expect(get.body["balance"]).to eq(10)
      expect(get.body["code"]).to eq(full_code)
    end

    it "can list Values" do
      list = values.list({limit: 1})
      expect(list.status).to eq(200)
      expect(list.max_limit).to eq(1000)
      expect(list.limit).to eq(1)
      expect(list.links).to_not be_nil
      expect(list.links.length).to eq(2)

      # check links
      expect(list.links[0][:limit]).to eq("1")
      expect(list.links[0][:after]).to_not be_nil
      expect(list.links[0][:url]).to eq("/v2/values?limit=1&after=" + list.links[0][:after])
      expect(list.links[0][:rel]).to eq("next")

      expect(list.links[1][:limit]).to eq("1")
      expect(list.links[1][:last]).to eq("true")
      expect(list.links[1][:url]).to eq("/v2/values?limit=1&last=true")
      expect(list.links[1][:rel]).to eq("last")
    end

    it "can update a Value" do
      update = values.update(value_id, {frozen: true, endDate: "2088-01-01T00:00:00.000Z"})
      expect(update.body["id"]).to eq(value_id)
      expect(update.body["frozen"]).to eq(true)
      expect(update.body["endDate"]).to eq("2088-01-01T00:00:00.000Z")
    end

    new_full_code = SecureRandom.alphanumeric.to_s
    it "can change a code to a specific code" do
      values.change_code(value_id, {code: new_full_code})

      # lookup full code
      display_code = values.get(value_id, {showCode: true})
      expect(display_code.body["code"]).to eq(new_full_code)
    end

    it "can generate a new code" do
      values.change_code(value_id, {generateCode: {length: 11}})

      # lookup full code
      display_code = values.get(value_id, {showCode: true})
      expect(display_code.body["code"]).to_not eq(new_full_code)
      expect(display_code.body["code"].length).to eq(11)
    end

    it "can delete a Value" do
      # delete only works for Value
      value_id_to_delete = SecureRandom.uuid
      create = values.create(
          {
              id: value_id_to_delete,
              currency: "USD",
              balance: 0
          })
      expect(create.status).to eq(201)

      delete = values.delete(value_id_to_delete)
      expect(delete.status).to eq(200)
    end

    describe "error cases an exception handling" do
      it "can't create a Value without an id - test basic error handling" do
        expect {values.create({currency: "USD"})
        }.to raise_error do |error|
          expect(error).to be_a(Lightrail::LightrailError)
          expect(error.status).to eq(422)
          expect(error.message).to_not be_nil
        end
      end

      it "can't get Value with wrong id - returns object not exception" do
        response = values.get("NOT_A_VALID_ID")
        expect(response.status).to eq(404)
      end

      describe "calling get with invalid id arguments" do
        it "can't get Value with id = {}" do
          expect {values.get({})}.to raise_error do |error|
            expect(error).to be_a(Lightrail::BadParameterError)
            expect(error.message).to eq("Argument id must be set.")
          end
        end

        it "can't get Value with id = nil" do
          expect {values.get(nil)}.to raise_error do |error|
            expect(error).to be_a(Lightrail::BadParameterError)
            expect(error.message).to eq("Argument id must be set.")
          end
        end
      end

      it "can't update a Value with wrong id - results in error" do
        expect {
          values.update("NOT_A_VALID_ID", {frozen: true})
        }.to raise_error do |error|
          expect(error).to be_a(Lightrail::LightrailError)
          expect(error.status).to eq(404)
        end
      end

      it "can't change a code with wrong id - results in error" do
        expect {
          values.change_code("NOT_A_VALID_ID", {generateCode: {}})
        }.to raise_error do |error|
          expect(error).to be_a(Lightrail::LightrailError)
          expect(error.status).to eq(404)
          expect(error.message).to_not be_nil
        end
      end

      it "can't delete a Value that doesn't exist - results in error" do
        expect {
          values.delete("NOT_A_VALID_ID")
        }.to raise_error do |error|
          expect(error).to be_a(Lightrail::LightrailError)
          expect(error.status).to eq(404)
        end
      end
    end

    # Extra test coverage
    it "can create a Value passing in string hash keys" do
      create = values.create(
          {
              "id" => SecureRandom.uuid,
              "currency" => "USD",
              "balance" => 15,
          })
      expect(create.body["currency"]).to eq("USD")
      expect(create.body["balance"]).to eq(15)
    end

    it "can create a Value passing in mixed hash" do
      create = values.create(
          {
              id: SecureRandom.uuid,
              "currency": "USD",
              "balance" => 15,
          })
      expect(create.body["currency"]).to eq("USD")
      expect(create.body["balance"]).to eq(15)
    end
  end
end
