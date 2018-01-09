require "spec_helper"

RSpec.describe Lightrail::Validator do
  subject(:validator) {Lightrail::Validator}

  let(:lr_argument_error) {Lightrail::LightrailArgumentError}

  let(:example_code) {'this-is-a-code'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_transaction_id) {'this-is-a-transaction-id'}
  let(:example_contact_id) {'this-is-a-contact-id'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}

  let(:code_charge_params) {{
      amount: 1,
      currency: 'USD',
      code: example_code,
  }}

  let(:card_id_charge_params) {{
      amount: 1,
      currency: 'USD',
      cardId: example_card_id,
  }}

  let(:contact_id_charge_params) {{
      amount: 1,
      currency: 'USD',
      contact_id: example_contact_id,
  }}

  let(:shopper_id_charge_params) {{
      amount: 1,
      currency: 'USD',
      shopper_id: example_shopper_id,
  }}

  let(:card_id_fund_params) {{
      card_id: example_card_id,
      amount: 20,
      currency: 'USD',
  }}

  let(:contact_id_fund_params) {{
      contact_id: example_contact_id,
      amount: 20,
      currency: 'USD',
  }}

  let(:shopper_id_fund_params) {{
      shopper_id: example_shopper_id,
      amount: 20,
      currency: 'USD',
  }}

  let(:transaction_response) {{
      cardId: 'card-123456',
      codeLastFour: 'TEST',
      currency: 'USD',
      transactionId: 'transaction-123456',
      transactionType: 'DRAWDOWN',
      userSuppliedId: '123-abc-456-def',
      value: -1,
  }}


  describe "grouped validator methods" do
    describe ".validate_charge_object!" do
      it "returns true when the required keys are present - charge by code" do
        expect(validator.validate_charge_object!(code_charge_params)).to be true
      end

      it "returns true when the required keys are present - charge by card" do
        expect(validator.validate_charge_object!(card_id_charge_params)).to be true
      end

      it "returns true when the required keys are present - charge by contact" do
        expect(Lightrail::Connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?cardType=ACCOUNT_CARD\&contactId=#{example_contact_id}\&currency=USD/)
                    .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})

        expect(validator.validate_charge_object!(contact_id_charge_params)).to be true
      end

      it "returns true when the required keys are present - charge by shopperId" do
        expect(Lightrail::Connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                    .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
        expect(Lightrail::Connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?cardType=ACCOUNT_CARD\&contactId=#{example_contact_id}\&currency=USD/)
                    .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})

        expect(validator.validate_charge_object!(shopper_id_charge_params)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        code_charge_params.delete(:code)
        expect {validator.validate_charge_object!(code_charge_params)}.to raise_error(lr_argument_error, /charge_params/)
        expect {validator.validate_charge_object!({})}.to raise_error(lr_argument_error, /charge_params/)
      end
    end

    describe ".validate_transaction_response!" do
      it "returns true when the required keys are present & formatted" do
        expect(validator.validate_transaction_response!(transaction_response)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        invalid_transaction_response = {'transaction' => {'transactionId' => 'this-is-a-transaction-id'}}
        expect {validator.validate_transaction_response!(invalid_transaction_response)}.to raise_error(lr_argument_error, /transaction_response/)
        expect {validator.validate_transaction_response!({})}.to raise_error(lr_argument_error, /transaction_response/)
        expect {validator.validate_transaction_response!([])}.to raise_error(lr_argument_error, /transaction_response/)
      end
    end

    describe ".validate_fund_object!" do
      it "returns true when the required keys are present & formatted - fund by card" do
        expect(validator.validate_fund_object!(card_id_fund_params)).to be true
      end

      it "returns true when the required keys are present & formatted - fund by contact" do
        expect(Lightrail::Connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?cardType=ACCOUNT_CARD\&contactId=#{example_contact_id}\&currency=USD/)
                    .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})

        expect(validator.validate_fund_object!(contact_id_fund_params)).to be true
      end

      it "returns true when the required keys are present & formatted - fund by shopperId" do
        expect(Lightrail::Connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/contacts\?userSuppliedId=#{example_shopper_id}/)
                    .and_return({"contacts" => [{"contactId" => "this-is-a-contact-id"}]})
        expect(Lightrail::Connection)
            .to receive(:make_get_request_and_parse_response)
                    .with(/cards\?cardType=ACCOUNT_CARD\&contactId=#{example_contact_id}\&currency=USD/)
                    .and_return({"cards" => [{"cardId" => "this-is-a-card-id"}]})
        expect(validator.validate_fund_object!(shopper_id_fund_params)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        fund_params = {amount: 1, currency: 'USD'}
        expect {validator.validate_fund_object!(fund_params)}.to raise_error(lr_argument_error, /fund_params/)
        expect {validator.validate_fund_object!({})}.to raise_error(lr_argument_error, /fund_params/)
        expect {validator.validate_fund_object!([])}.to raise_error(lr_argument_error, /fund_params/)
      end
    end

    describe ".validate_ping_response!" do
      it "returns true when the required keys are present & formatted" do
        ping_response = {'user' => {'username' => 'test@test.com'}}
        expect(validator.validate_ping_response!(ping_response)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        ping_response = {'user' => {'username' => ''}}
        expect {validator.validate_ping_response!(ping_response)}.to raise_error(lr_argument_error, /ping_response/)
        expect {validator.validate_ping_response!({})}.to raise_error(lr_argument_error, /ping_response/)
        expect {validator.validate_ping_response!([])}.to raise_error(lr_argument_error, /ping_response/)
      end
    end
  end

  describe "single validator methods" do
    describe ".validate_card_id!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_card_id! (example_card_id)).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_card_id! ('')}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.validate_card_id! ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_card_id! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_card_id! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_card_id! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_contact_id!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_contact_id! (example_contact_id)).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_contact_id! ('')}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.validate_contact_id! ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_contact_id! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_contact_id! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_contact_id! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_shopper_id!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_shopper_id! (example_shopper_id)).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_shopper_id! ('')}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.validate_shopper_id! ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_shopper_id! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_shopper_id! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_shopper_id! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_code!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_code! (example_code)).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_code! ('')}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.validate_code! ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_code! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_code! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_code! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_transaction_id!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_transaction_id! (example_transaction_id)).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_transaction_id! ('')}.to raise_error(lr_argument_error), "called with empty string"
        # expect{validator.is_transaction_id_valid? ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_transaction_id! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_transaction_id! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_transaction_id! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_amount!" do
      it "returns true for an integer" do
        expect(validator.validate_amount! (5)).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_amount! (5.5)}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.validate_amount! ('five')}.to raise_error(lr_argument_error), "called with number as string"
        expect {validator.validate_amount! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_amount! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_currency!" do
      it "returns true for an string of the right format" do
        expect(validator.validate_currency! ('USD')).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_currency! ('XXXX')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_currency! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_currency! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_currency! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_username!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_username! ('test@test.com')).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_username! ('')}.to raise_error(lr_argument_error), "called with empty string"
        # expect{validator.is_transaction_id_valid? ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_username! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_username! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_username! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end
  end
end
