require "spec_helper"
require "securerandom"
require "dotenv"
Dotenv.load

RSpec.describe Lightrail::Contacts do
  subject(:factory) {Lightrail::Contacts}

  xdescribe "Contact Tests" do
    Lightrail.api_key = ENV["LIGHTRAIL_TEST_API_KEY"]

    contact_id = SecureRandom.uuid
    email = "alice+#{SecureRandom.alphanumeric.to_s}@example.com"
    it "can create a contact" do
      create = factory.create({
                                  id: contact_id,
                                  firstName: "alice",
                                  email: email
                              })
      expect(create.status).to eq(201)
      expect(create.body["id"]).to eq(contact_id)
      expect(create.body["firstName"]).to eq("alice")
      expect(create.body["email"]).to eq(email)
    end

    it "can get a contact" do
      create = factory.get(contact_id)
      expect(create.status).to eq(200)
      expect(create.body["id"]).to eq(contact_id)
      expect(create.body["firstName"]).to eq("alice")
      expect(create.body["email"]).to eq(email)
    end

    it "can list contacts" do
      list = factory.list
      expect(list.status).to eq(200)

      # make sure the objects that come back look like a currency
      expect(list.body[0].key?("id")).to be_truthy
      expect(list.body[0].key?("email")).to be_truthy
      expect(list.body[0].key?("firstName")).to be_truthy
    end

    it "can list contacts and filter by id" do
      list = factory.list({id: contact_id})
      expect(list.status).to eq(200)
      expect(list.body[0]["id"]).to eq(contact_id)
      expect(list.body[0]["email"]).to eq(email)
    end

    it "can update contact" do
      update = factory.update(contact_id, {firstName: "who_is_alice"})
      expect(update.status).to eq(200)
      expect(update.body["firstName"]).to eq("who_is_alice")
    end

    it "can attach a value to a contact by valueId" do
      # create the value
      value_id = SecureRandom.uuid
      create = Lightrail::Values.create(
          {
              id: value_id,
              currency: "USD",
              balance: 10,
          })
      expect(create.status).to eq(201)

      # attach
      attach = factory.attach_value_to_contact(contact_id, {valueId: value_id})
      expect(attach.status).to eq(200)
      expect(attach.body["contactId"]).to eq(contact_id)
    end

    it "can attach a value to a contact by code" do
      # create the value
      code = SecureRandom.alphanumeric.to_s
      create = Lightrail::Values.create(
          {
              id: SecureRandom.uuid,
              currency: "USD",
              balance: 10,
              code: code
          })
      expect(create.status).to eq(201)

      # attach
      attach = factory.attach_value_to_contact(contact_id, {code: code})
      expect(attach.status).to eq(200)
      expect(attach.body["contactId"]).to eq(contact_id)
    end

    it "can list contact values - expect 2 attached" do
      list = factory.list_contact_values(contact_id)
      expect(list.status).to eq(200)
      expect(list.body.length).to eq(2)
    end

    it "can delete a Contact" do
      # create new contact since you can't delete contacts that have attached Values
      contact_id_to_delete = SecureRandom.uuid
      create = factory.create({
                                  id: contact_id_to_delete
                              })
      expect(create.status).to eq(201)

      delete = factory.delete(contact_id_to_delete)
      expect(delete.status).to eq(200)
    end

    # Error cases and exception handling
    it "can't get a contact that doesn't exist" do
      create = factory.get("NO_SUCH_CURRENCY")
      expect(create.status).to eq(404)
    end

    describe "calling get with invalid id arguments" do
      it "can't get Contact with id = {}" do
        expect {factory.get({})}.to raise_error do |error|
          expect(error).to be_a(Lightrail::BadParameterError)
          expect(error.message).to eq("Argument id must be set.")
        end
      end

      it "can't get Contact with id = nil" do
        expect {factory.get(nil)}.to raise_error do |error|
          expect(error).to be_a(Lightrail::BadParameterError)
          expect(error.message).to eq("Argument id must be set.")
        end
      end
    end

    it "can't update a contact that doesn't exist - throws exception" do
      expect {factory.update("NO_SUCH_CONTACT", {firstName: "nobody"})}.to raise_error do |error|
        expect(error).to be_a(Lightrail::LightrailError)
        expect(error.status).to eq(404)
      end
    end

    it "can't attach a value to a Contact that doesn't exist - throws exception" do
      expect {factory.attach_value_to_contact("NO_SUCH_CONTACT", {valueId: "does not matter"})}.to raise_error do |error|
        expect(error).to be_a(Lightrail::LightrailError)
        expect(error.status).to eq(404)
      end
    end

    it "can't delete a contact that doesn't exist - throws exception" do
      expect {factory.delete("NO_SUCH_CONTACT")}.to raise_error do |error|
        expect(error).to be_a(Lightrail::LightrailError)
        expect(error.status).to eq(404)
      end
    end
  end
end
