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

    def self.get_maximum_value(card_id)
      card_details = self.get_details(card_id)
      maximum_value = 0
      card_details['valueStores'].each do |valueStore|
        if valueStore['state'] == 'ACTIVE'
          maximum_value += valueStore['value']
        end
      end
      maximum_value
    end

    def self.get_details(card_id)
      response = Lightrail::Connection.make_get_request_and_parse_response("cards/#{card_id}/details")
      response['details']
    end

  end
end