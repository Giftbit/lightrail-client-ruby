module Lightrail
  class Code

    def self.charge(charge_params)
      Lightrail::Transaction.charge_code(charge_params, false)
    end

    def self.simulate_charge(charge_params)
      params_for_simulation = Lightrail::Validator.set_nsf_for_simulate!(charge_params)
      Lightrail::Transaction.charge_code(params_for_simulation, true)
    end

    def self.get_maximum_value(code)
      code_details = self.get_details(code)
      maximum_value = 0
      code_details['valueStores'].each do |valueStore|
        if valueStore['state'] == 'ACTIVE'
          maximum_value += valueStore['value']
        end
      end
      maximum_value
    end

    def self.get_details(code)
      response = Lightrail::Connection.make_get_request_and_parse_response("codes/#{code}/details")
      response['details']
    end

  end
end