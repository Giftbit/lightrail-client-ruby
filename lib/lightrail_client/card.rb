module Lightrail
  class Card < Lightrail::LightrailObject

    def self.charge(charge_params)
      Lightrail::Transaction.charge_card(charge_params, false)
    end

    def self.simulate_charge(charge_params)
      params_for_simulation = Lightrail::Validator.set_nsf_for_simulate!(charge_params)
      Lightrail::Transaction.charge_card(params_for_simulation, true)
    end

    def self.fund(fund_params)
      Lightrail::Transaction.fund_card(fund_params)
    end

    def self.get_balance_details(card_id)
      response = Lightrail::Connection.make_get_request_and_parse_response("cards/#{card_id}/balance")
      response['balance']
    end

    def self.get_total_balance(card_id)
      balance_details = self.get_balance_details(card_id)
      total = balance_details['principal']['currentValue']
      balance_details['attached'].reduce(total) do |sum, valueStore|
        if valueStore['state'] == "ACTIVE"
          total += valueStore['currentValue']
        end
      end
      total
    end

  end
end