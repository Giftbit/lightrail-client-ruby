require "spec_helper"
require "securerandom"
require "dotenv"
Dotenv.load

RSpec.describe Lightrail::Programs do
  subject(:factory) {Lightrail::Programs}

  describe "Program Tests" do
    Lightrail.api_key = ENV["LIGHTRAIL_TEST_API_KEY"]

    program_id = SecureRandom.uuid
    it "can create a program" do
      create = factory.create({
                                  id: program_id,
                                  currency: "USD",
                                  name: "Test Program"
                              })
      expect(create.status).to eq(201)
      expect(create.body["id"]).to eq(program_id)
      expect(create.body["currency"]).to eq("USD")
      expect(create.body["name"]).to eq("Test Program")
    end

    it "can get a program" do
      get = factory.get(program_id)
      expect(get.status).to eq(200)
      expect(get.body["id"]).to eq(program_id)
      expect(get.body["currency"]).to eq("USD")
      expect(get.body["name"]).to eq("Test Program")
    end

    it "can list programs" do
      list = factory.list
      expect(list.status).to eq(200)

      # make sure the objects that come back look like a currency
      expect(list.body[0].key?("name")).to be_truthy
      expect(list.body[0].key?("currency")).to be_truthy
    end

    it "can update a program" do
      list = factory.update(program_id, {name: "New Test Name"})
      expect(list.status).to eq(200)
      expect(list.body["name"]).to eq("New Test Name")
    end

    describe "issuances" do
      issuance_id = SecureRandom.uuid
      it "can create an issuance" do
        create = factory.create_issuance(program_id, {
            id: issuance_id,
            name: "Test Issuance",
            count: 1
        })
        expect(create.status).to eq(201)
        expect(create.body["id"]).to eq(issuance_id)
        expect(create.body["count"]).to eq(1)
        expect(create.body["name"]).to eq("Test Issuance")
      end

      it "can get an issuance" do
        get = factory.get_issuance(program_id, issuance_id)
        expect(get.status).to eq(200)
        expect(get.body["id"]).to eq(issuance_id)
        expect(get.body["count"]).to eq(1)
        expect(get.body["name"]).to eq("Test Issuance")
      end

      it "can list issuances" do
        list = factory.list_issuances(program_id)
        expect(list.status).to eq(200)
        expect(list.body[0]["id"]).to eq(issuance_id)
        expect(list.body[0]["count"]).to eq(1)
        expect(list.body[0]["name"]).to eq("Test Issuance")
      end
    end

    it "can delete a program" do
      # create new program since you can't delete program that have issuances or values created under them
      program_id_to_delete = SecureRandom.uuid
      create = factory.create({
                                  id: program_id_to_delete,
                                  name: "Will be deleted...",
                                  currency: "USD"
                              })
      expect(create.status).to eq(201)

      delete = factory.delete(program_id_to_delete)
      expect(delete.status).to eq(200)
    end

    # TODO - Basic error handling (see contacts_spec.rb)
  end

end
