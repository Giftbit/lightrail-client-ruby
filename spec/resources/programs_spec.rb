require "spec_helper"
require "securerandom"
require "dotenv"
Dotenv.load

RSpec.describe Lightrail::Programs do
  subject(:programs) {Lightrail::Programs}

  describe "Program Tests" do
    Lightrail.api_key = ENV["LIGHTRAIL_TEST_API_KEY"]

    program_id = SecureRandom.uuid
    it "can create a program" do
      create = programs.create({
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
      get = programs.get(program_id)
      expect(get.status).to eq(200)
      expect(get.body["id"]).to eq(program_id)
      expect(get.body["currency"]).to eq("USD")
      expect(get.body["name"]).to eq("Test Program")
    end

    it "can list programs" do
      list = programs.list
      expect(list.status).to eq(200)

      # make sure the objects that come back look like a currency
      expect(list.body[0].key?("name")).to be_truthy
      expect(list.body[0].key?("currency")).to be_truthy
    end

    it "can update a program" do
      list = programs.update(program_id, {name: "New Test Name"})
      expect(list.status).to eq(200)
      expect(list.body["name"]).to eq("New Test Name")
    end

    describe "issuances" do
      issuance_id = SecureRandom.uuid
      it "can create an issuance" do
        create = programs.create_issuance(program_id, {
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
        get = programs.get_issuance(program_id, issuance_id)
        expect(get.status).to eq(200)
        expect(get.body["id"]).to eq(issuance_id)
        expect(get.body["count"]).to eq(1)
        expect(get.body["name"]).to eq("Test Issuance")
      end

      it "can list issuances" do
        list = programs.list_issuances(program_id)
        expect(list.status).to eq(200)
        expect(list.body[0]["id"]).to eq(issuance_id)
        expect(list.body[0]["count"]).to eq(1)
        expect(list.body[0]["name"]).to eq("Test Issuance")
      end
    end

    it "can delete a program" do
      # create new program since you can't delete program that have issuances or values created under them
      program_id_to_delete = SecureRandom.uuid
      create = programs.create({
                                   id: program_id_to_delete,
                                   name: "Will be deleted...",
                                   currency: "USD"
                               })
      expect(create.status).to eq(201)

      delete = programs.delete(program_id_to_delete)
      expect(delete.status).to eq(200)
    end

    describe "error cases an exception handling" do
      it "can't get with non-existent id" do
        create = programs.get("NON_EXISTENT_ID")
        expect(create.status).to eq(404)
      end

      describe "calling get with invalid id arguments" do
        it "can't get with id = {}  - throws exception" do
          expect {programs.get({})}.to raise_error do |error|
            expect(error).to be_a(Lightrail::BadParameterError)
            expect(error.message).to eq("Argument id must be set.")
          end
        end

        it "can't get with id = nil - throws exception" do
          expect {programs.get(nil)}.to raise_error do |error|
            expect(error).to be_a(Lightrail::BadParameterError)
            expect(error.message).to eq("Argument id must be set.")
          end
        end
      end

      it "can't update with non-existent id - throws exception" do
        expect {programs.update("NON_EXISTENT_ID", {name: "New Name"})}.to raise_error do |error|
          expect(error).to be_a(Lightrail::LightrailError)
          expect(error.status).to eq(404)
        end
      end

      # Currently a bug in the API
      # it "can't delete with non-existent id - throws exception" do
      #   expect {programs.delete("NON_EXISTENT_ID")}.to raise_error do |error|
      #     expect(error).to be_a(Lightrail::LightrailError)
      #     expect(error.status).to eq(404)
      #   end
      # end
    end
  end
end
