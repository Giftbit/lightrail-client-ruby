require "spec_helper"

RSpec.describe Lightrail::Contact do
  subject(:contact) {Lightrail::Contact}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_contact_id) {'this-is-a-contact-id'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_currency) {'ABC'}

  let(:charge_params_with_contact_id) {{
      value: -1,
      currency: 'ABC',
      contact_id: example_contact_id,
  }}

  let(:charge_params_with_shopper_id) {{
      value: -1,
      currency: 'ABC',
      shopper_id: example_shopper_id,
  }}


  describe ".charge" do
    it "charges a contact's account given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency))
                  .and_return({"transaction" => {}})
      contact.charge(charge_params_with_contact_id)
    end

    it "charges a contact's account given a shopperId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                  .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency))
                  .and_return({"transaction" => {}})
      contact.charge(charge_params_with_shopper_id)
    end
  end

  describe "utility methods" do
    describe ".get_account_card_id_by_contact_id" do
      it "gets the account card id" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                    .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
        contact.get_account_card_id_by_contact_id(example_contact_id, example_currency)
      end

      it "throws an error if no results" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                    .and_return({"cards" => []})

        expect {contact.get_account_card_id_by_contact_id(example_contact_id, example_currency)}.to raise_error(Lightrail::CouldNotFindObjectError)
      end
    end

    describe ".get_contact_id_from_id_or_shopper_id" do
      it "gets the ID of the first contact returned" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                    .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
        contact_id = contact.get_contact_id_from_id_or_shopper_id(charge_params_with_shopper_id)
        expect(contact_id).to eq(example_contact_id)
      end

      it "throws an error if no results" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/contacts\?userSuppliedId=not-here/)
                    .and_return({"contacts" => []})

        expect {contact.get_contact_id_from_id_or_shopper_id({shopper_id: 'not-here'})}.to raise_error(Lightrail::CouldNotFindObjectError)
      end
    end
  end

end