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
  end

  describe ".charge_account" do
    it "charges a contact's account given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency))
                  .and_return({"transaction" => {}})
      contact.charge_account(charge_params_with_contact_id)
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
      contact.charge_account(charge_params_with_shopper_id)
    end
  end

  describe ".simulate_account_charge" do
    it "simulates charging a contact's account given a shopperId & currency" do
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
                  .with(/cards\/#{example_card_id}\/transactions\/dryRun/, hash_including(:value, :currency))
                  .and_return({"transaction" => {}})
      contact.simulate_account_charge(charge_params_with_shopper_id)
    end

    it "simulates charging a contact's account given a shopperId & currency" do
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
                  .with(/cards\/#{example_card_id}\/transactions\/dryRun/, hash_including(:value, :currency))
                  .and_return({"transaction" => {}})
      contact.simulate_account_charge(charge_params_with_shopper_id)
    end
  end

  describe ".fund_account" do
    it "funds a contact's account given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency))
                  .and_return({"transaction" => {}})
      contact.fund_account(fund_params_with_contact_id)
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
      contact.fund_account(fund_params_with_shopper_id)
    end
  end

  describe ".get_account_details" do
    it "gets the account card details given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\/#{example_card_id}\/details/)
                  .and_return({"details" => {}})
      contact.get_account_details({contact_id: 'this-is-a-contact-id', currency: 'ABC'})
    end

    it "gets the account card details given a shopperId & currency" do
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
                  .with(/cards\/#{example_card_id}\/details/)
                  .and_return({"details" => {}})
      contact.get_account_details({shopper_id: 'this-is-a-shopper-id', currency: 'ABC'})
    end
  end

  describe ".get_maximum_account_value" do
    it "gets the maximum value of the account given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(Lightrail::Card)
          .to receive(:get_maximum_value)
                  .with(example_card_id)
      contact.get_maximum_account_value({contact_id: 'this-is-a-contact-id', currency: 'ABC'})
    end

    it "gets the maximum value of the account given a shopperId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                  .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
      expect(Lightrail::Card)
          .to receive(:get_maximum_value)
                  .with(example_card_id)
      contact.get_maximum_account_value({shopper_id: 'this-is-a-shopper-id', currency: 'ABC'})
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

    describe ".replace_contact_id_or_shopper_id_with_card_id" do
      it "replaces a contact id with a card id" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                    .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})

        new_params = contact.replace_contact_id_or_shopper_id_with_card_id(charge_params_with_contact_id)

        expect(new_params[:card_id]).to eq(example_card_id)
        expect(new_params[:contact_id]).to be nil
      end

      it "replaces a shopper id with a card id" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                    .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                    .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})

        new_params = contact.replace_contact_id_or_shopper_id_with_card_id(charge_params_with_shopper_id)

        expect(new_params[:card_id]).to eq(example_card_id)
        expect(new_params[:shopper_id]).to be nil
      end

      it "does not overwrite an existing card id if there is no contact id or shopper id" do
        new_params = contact.replace_contact_id_or_shopper_id_with_card_id({card_id: 'this-is-a-pre-existing-card-id', currency: 'ABC'})
        expect(new_params[:card_id]).to eq('this-is-a-pre-existing-card-id')
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