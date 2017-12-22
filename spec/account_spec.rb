require "spec_helper"

RSpec.describe Lightrail::Account do
  subject(:account) {Lightrail::Account}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_contact_id) {'this-is-a-contact-id'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_currency) {'ABC'}

  let(:create_account_params_with_shopper_id) {{
      shopper_id: example_shopper_id,
      currency: example_currency,
      user_supplied_id: 'this-is-a-new-account',
  }}

  let(:create_account_params_with_contact_id) {{
      contact_id: example_contact_id,
      currency: example_currency,
      user_supplied_id: 'this-is-a-new-account',
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
    it "creates a new account given a shopperId & currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                  .and_return({"contacts" => [{"contactId" => example_contact_id}]})
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/cards/, hash_including(:cardType => 'ACCOUNT_CARD', :contactId => example_contact_id, :userSuppliedId => 'this-is-a-new-account'))
                  .and_return({"card" => {}})
      account.create(create_account_params_with_shopper_id)
    end

    it "creates a new account given a contactId & currency" do
      expect(lightrail_connection)
          .to receive(:make_post_request_and_parse_response)
                  .with(/cards/, hash_including(:cardType => 'ACCOUNT_CARD', :contactId => example_contact_id, :userSuppliedId => 'this-is-a-new-account'))
                  .and_return({"card" => {}})
      account.create(create_account_params_with_contact_id)
    end

    describe "error handling" do
      it "throws an error if no contactId or shopperId" do
        expect {account.create({currency: 'ABC', userSuppliedId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)
      end

      it "throws an error if no currency" do
        expect {account.create({contactId: 'ABC', userSuppliedId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)
      end

      it "throws an error if no userSuppliedId" do
        expect {account.create({currency: 'ABC', shopperId: 'id'})}.to raise_error(Lightrail::LightrailArgumentError)
      end
    end
  end

  describe ".retrieve_by_contact_id_and_currency" do
    it "retrieves an account card by contactId and currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?cardType=ACCOUNT_CARD\&contactId=#{example_contact_id}\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"contactId" => example_contact_id, "cardId" => example_card_id}]})
      account.retrieve_by_contact_id_and_currency(example_contact_id, example_currency)
    end

    describe "error handling" do
      it "throws an error if no contactId" do
        expect {account.retrieve_by_contact_id_and_currency('', 'ABC')}.to raise_error(Lightrail::LightrailArgumentError)
      end

      it "throws an error if no currency" do
        expect {account.retrieve_by_contact_id_and_currency('ABC', '')}.to raise_error(Lightrail::LightrailArgumentError)
      end
    end
  end

  describe ".retrieve_by_shopper_id_and_currency" do
    it "retrieves an account card by shopperId and currency" do
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                  .and_return({"contacts" => [{"contactId" => example_contact_id}]})
      expect(lightrail_connection)
          .to receive(:make_get_request_and_parse_response)
                  .with(/cards\?cardType=ACCOUNT_CARD\&contactId=#{example_contact_id}\&currency=#{example_currency}/)
                  .and_return({"cards" => [{"contactId" => example_contact_id, "cardId" => example_card_id}]})
      account.retrieve_by_shopper_id_and_currency(example_shopper_id, example_currency)
    end

    describe "error handling" do
      it "throws an error if no shopperId" do
        expect {account.retrieve_by_shopper_id_and_currency('', 'ABC')}.to raise_error(Lightrail::LightrailArgumentError)
      end

      it "throws an error if no currency" do
        expect {account.retrieve_by_shopper_id_and_currency('ABC', '')}.to raise_error(Lightrail::LightrailArgumentError)
      end
    end
  end

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
      account.charge(charge_params_with_contact_id)
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
      account.charge(charge_params_with_shopper_id)
    end
  end

  describe ".simulate_charge" do
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
      account.simulate_charge(charge_params_with_shopper_id)
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
      account.simulate_charge(charge_params_with_shopper_id)
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
      account.fund(fund_params_with_contact_id)
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
      account.fund(fund_params_with_shopper_id)
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
      account.get_account_details({contact_id: 'this-is-a-contact-id', currency: 'ABC'})
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
      account.get_account_details({shopper_id: 'this-is-a-shopper-id', currency: 'ABC'})
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
      account.get_maximum_account_value({contact_id: 'this-is-a-contact-id', currency: 'ABC'})
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
      account.get_maximum_account_value({shopper_id: 'this-is-a-shopper-id', currency: 'ABC'})
    end
  end

  describe "utility methods" do
    describe ".replace_contact_id_or_shopper_id_with_card_id" do
      it "replaces a contact id with a card id" do
        expect(lightrail_connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?contactId=#{example_contact_id}\&cardType=ACCOUNT_CARD\&currency=#{example_currency}/)
                    .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})

        new_params = account.replace_contact_id_or_shopper_id_with_card_id(charge_params_with_contact_id)

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

        new_params = account.replace_contact_id_or_shopper_id_with_card_id(charge_params_with_shopper_id)

        expect(new_params[:card_id]).to eq(example_card_id)
        expect(new_params[:shopper_id]).to be nil
      end

      it "does not overwrite an existing card id if there is no contact id or shopper id" do
        new_params = account.replace_contact_id_or_shopper_id_with_card_id({card_id: 'this-is-a-pre-existing-card-id', currency: 'ABC'})
        expect(new_params[:card_id]).to eq('this-is-a-pre-existing-card-id')
      end
    end

  end


end