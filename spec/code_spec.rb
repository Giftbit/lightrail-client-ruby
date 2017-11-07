require "spec_helper"

RSpec.describe Lightrail::Code do
  subject(:code) {Lightrail::Code}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_code) {'this-is-a-code'}

  let(:charge_params) {{
      value: 1,
      currency: 'USD',
      code: example_code,
  }}

  let(:details_response) {{
      "valueStores" => [
          {"valueStoreType" => "PRINCIPAL", "value" => 675, "state" => "ACTIVE"},
          {"valueStoreType" => "ATTACHED", "value" => 1250, "state" => "ACTIVE"},
          {"valueStoreType" => "ATTACHED", "value" => 3175, "state" => "EXPIRED"}
      ]
  }}

  describe ".charge" do
    it "posts a charge to a code" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{example_code}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      code.charge(charge_params)
    end
  end

  describe ".simulate_charge" do
    it "simulates posting a charge to a code" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{example_code}\/transactions\/dryRun/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      code.simulate_charge(charge_params)
    end

    it "sets 'nsf' to 'false' by default" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{example_code}\/transactions\/dryRun/, hash_including(nsf: false)).and_return({"transaction" => {}})
      code.simulate_charge(charge_params)
    end
  end

  describe ".get_details" do
    it "gets the code details" do
      expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/codes\/#{example_code}\/details/).and_return({"details" => {}})
      code.get_details(example_code)
    end
  end

  describe ".get_maximum_value" do
    it "tallies the value of all active value stores" do
      expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/codes\/#{example_code}\/details/).and_return({"details" => details_response})
      max_val = code.get_maximum_value(example_code)
      expect(max_val).to be 1925
    end
  end

end