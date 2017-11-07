require "spec_helper"

RSpec.describe Lightrail::Card do
  subject(:card) {Lightrail::Card}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_card_id) {'this-is-a-card-id'}

  let(:charge_params) {{
      value: -1,
      currency: 'USD',
      card_id: example_card_id,
  }}

  let(:fund_params) {{
      value: 1,
      currency: 'USD',
      card_id: example_card_id,
  }}

  let(:details_response) {{
      "valueStores" => [
          {"valueStoreType" => "PRINCIPAL", "value" => 675, "state" => "ACTIVE"},
          {"valueStoreType" => "ATTACHED", "value" => 1250, "state" => "ACTIVE"},
          {"valueStoreType" => "ATTACHED", "value" => 3175, "state" => "EXPIRED"}
      ]
  }}

  describe ".charge" do
    it "posts a charge to a card" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      card.charge(charge_params)
    end
  end

  describe ".simulate_charge" do
    it "simulates posting a charge to a card" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions\/dryRun/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      card.simulate_charge(charge_params)
    end

    it "sets 'nsf' to 'false' by default" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions\/dryRun/, hash_including(nsf: false)).and_return({"transaction" => {}})
      card.simulate_charge(charge_params)
    end
  end

  describe ".fund" do
    it "funds a card" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      card.fund(fund_params)
    end
  end

  describe ".get_details" do
    it "gets the card details" do
      expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/cards\/#{example_card_id}\/details/).and_return({"details" => {}})
      card.get_details(example_card_id)
    end
  end

  describe ".get_maximum_value" do
    it "tallies the value of all active value stores" do
      expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/cards\/#{example_card_id}\/details/).and_return({"details" => details_response})
      max_val = card.get_maximum_value(example_card_id)
      expect(max_val).to be 1925
    end
  end
end