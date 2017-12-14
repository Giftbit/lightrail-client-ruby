require "spec_helper"

RSpec.describe Lightrail::Contact do
  subject(:contact) {Lightrail::Contact}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_contact_id) {'this-is-a-contact-id'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_currency) {'ABC'}

  let(:create_params_with_shopper_id) {{
      shopper_id: example_shopper_id,
  }}

  let(:create_params_with_user_supplied_id) {{
      user_supplied_id: example_shopper_id,
  }}

  let(:create_params_with_name) {{
      shopper_id: example_shopper_id,
      first_name: 'Firstname',
      last_name: 'Lastname',
  }}

  let(:charge_params_with_shopper_id) {{
      value: -1,
      currency: 'ABC',
      shopper_id: example_shopper_id,
  }}


  describe ".create" do
    it "creates a new contact given a shopperId" do
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/contacts/, hash_including(:userSuppliedId))
                  .and_return({"contact" => {"userSuppliedId" => "this-is-a-shopper-id"}})
      contact.create(create_params_with_shopper_id)
    end

    it "creates a new contact given a userSuppliedId" do
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/contacts/, hash_including(:userSuppliedId))
                  .and_return({"contact" => {"userSuppliedId" => "this-is-a-shopper-id"}})
      contact.create(create_params_with_user_supplied_id)
    end

    it "creates a new contact with names if present" do
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/contacts/, hash_including(:userSuppliedId, :firstName, :lastName))
                  .and_return({"contact" => {}})
      contact.create(create_params_with_name)
    end

    it "creates a new contact with email if present" do
      create_params_with_email = create_params_with_shopper_id.clone
      create_params_with_email[:email] = 'email@example.com'
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/contacts/, hash_including(:userSuppliedId, :email))
                  .and_return({"contact" => {}})
      contact.create(create_params_with_email)
    end
  end

  describe ".retrieve_by_shopper_id" do
    it "retrieves a contact by its shopperId (contact userSuppliedId)" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                  .and_return({"contacts" => []})
      contact.retrieve_by_shopper_id(example_shopper_id)
    end
  end

  describe ".retrieve_by_contact_id" do
    it "retrieves a contact by its contactId" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/contacts\/#{example_contact_id}/)
                  .and_return({"contact" => {}})
      contact.retrieve_by_contact_id(example_contact_id)
    end
  end

  describe "utility methods" do
    describe ".get_contact_id_from_id_or_shopper_id" do
      it "gets the ID of the first contact returned" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                    .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
        contact_id = contact.get_contact_id_from_id_or_shopper_id(charge_params_with_shopper_id)
        expect(contact_id).to eq(example_contact_id)
      end

      it "returns nil if no results" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/contacts\?userSuppliedId=not-here/)
                    .and_return({"contacts" => []})

        contact_id_result = contact.get_contact_id_from_id_or_shopper_id({shopper_id: 'not-here'})
        expect(contact_id_result).to be(nil)
      end
    end
  end

end