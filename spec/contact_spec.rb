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

  let(:fund_params_with_contact_id) {{
      value: 1,
      currency: 'ABC',
      contact_id: example_contact_id,
  }}

  let(:fund_params_with_shopper_id) {{
      value: 1,
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

  describe ".fund" do
    it "funds a contact's account given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency))
                  .and_return({"transaction" => {}})
      contact.fund(fund_params_with_contact_id)
    end

    it "funds a contact's account given a shopperId & currency" do
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
      contact.fund(fund_params_with_shopper_id)
    end
  end

  describe ".get_balance_details" do
    it "gets the balance details given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\/#{example_card_id}\/balance/)
                  .and_return({"balance" => {}})
      contact.get_balance_details({contact_id: 'this-is-a-contact-id', currency: 'ABC'})
    end

    it "gets the balance details given a shopperId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                  .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\/#{example_card_id}\/balance/)
                  .and_return({"balance" => {}})
      contact.get_balance_details({shopper_id: 'this-is-a-shopper-id', currency: 'ABC'})
    end
  end

  describe ".get_total_balance" do
    it "gets the total balance given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(Lightrail::Card)
          .to receive(:get_total_balance)
                  .with(example_card_id)
      contact.get_total_balance({contact_id: 'this-is-a-contact-id', currency: 'ABC'})
    end

    it "gets the total balance given a shopperId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                  .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(Lightrail::Card)
          .to receive(:get_total_balance)
                  .with(example_card_id)
      contact.get_total_balance({shopper_id: 'this-is-a-shopper-id', currency: 'ABC'})
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

      it "returns nil if no results" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                    .and_return({"cards" => []})

        contact_result = contact.get_account_card_id_by_contact_id(example_contact_id, example_currency)
        expect(contact_result).to be(nil)
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