module Lightrail
  class Code

    def self.charge(charge_params)
      Lightrail::Transaction.charge_code(charge_params, false)
    end

    def self.simulate_charge(charge_params)
      params_for_simulation = Lightrail::Validator.set_nsf_for_simulate!(charge_params)
      Lightrail::Transaction.charge_code(params_for_simulation, true)
    end

    def self.get_balance_details(code)
      response = Lightrail::Connection.make_get_request_and_parse_response("codes/#{code}/balance/details")
      response['balance']
    end

    def self.get_total_balance(code)
      balance_details = self.get_balance_details(code)
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