module Lightrail
  class Validator
    def self.set_params_for_code_drawdown!(charge_params)
      validated_params = charge_params.clone
      begin
        return validated_params if ((validated_params.is_a? Hash) &&
            self.set_code!(validated_params, validated_params) &&
            self.validate_amount!(validated_params[:amount] || validated_params[:value]) &&
            self.validate_currency!(validated_params[:currency]) &&
            self.get_or_set_userSuppliedId!(validated_params))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid charge_params for set_params_for_code_drawdown!: #{charge_params.inspect}")
    end

    def self.set_params_for_code_pending!(charge_params)
      begin
        validated_params = self.set_params_for_code_drawdown!(charge_params)
        validated_params[:pending] = true
        return validated_params
      rescue Lightrail::LightrailError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid charge_params for set_params_for_code_pending!: #{charge_params.inspect}")
    end

    def self.set_params_for_card_id_drawdown!(charge_params)
      validated_params = charge_params.clone
      begin
        return validated_params if ((validated_params.is_a? Hash) &&
            (self.set_cardId!(validated_params, validated_params) ||
                Lightrail::Contact.replace_contact_id_or_shopper_id_with_card_id(validated_params)) &&
            self.validate_amount!(validated_params[:amount] || validated_params[:value]) &&
            self.validate_currency!(validated_params[:currency]) &&
            self.get_or_set_userSuppliedId!(validated_params))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid charge_params for set_params_for_card_id_drawdown!: #{charge_params.inspect}")
    end

    def self.set_params_for_card_id_fund!(fund_params)
      validated_params = fund_params.clone
      begin
        return validated_params if ((validated_params.is_a? Hash) &&
            (self.set_cardId!(validated_params, validated_params) ||
                Lightrail::Contact.replace_contact_id_or_shopper_id_with_card_id(validated_params)) &&
            self.validate_amount!(validated_params[:amount] || validated_params[:value]) &&
            self.validate_currency!(validated_params[:currency]) &&
            self.get_or_set_userSuppliedId!(validated_params))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid fund_params for set_params_for_card_id_fund!: #{fund_params.inspect}")
    end

    def self.set_nsf_for_simulate!(charge_params)
      params_for_simulate = charge_params.clone
      if (!params_for_simulate.key?([:nsf]) && !params_for_simulate.key?(['nsf']))
        params_for_simulate[:nsf] = false
      end
      params_for_simulate
    end

    def self.set_params_for_card_id_pending!(charge_params)
      begin
        validated_params = self.set_params_for_card_id_drawdown!(charge_params)
        validated_params[:pending] = true
        return validated_params
      rescue Lightrail::LightrailError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid charge_params for set_params_for_card_id_pending!!: #{charge_params.inspect}")
    end

    def self.set_params_for_acting_on_existing_transaction!(original_transaction, new_request_body={})
      validated_params = new_request_body.clone
      validated_params[:original_transaction] = original_transaction
      begin
        return validated_params if ((validated_params.is_a? Hash) &&
            (validated_params[:original_transaction].is_a? Hash) &&
            self.set_cardId!(validated_params, validated_params[:original_transaction]) &&
            self.set_transactionId!(validated_params, validated_params[:original_transaction]) &&
            self.get_or_set_userSuppliedId!(validated_params))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid params for set_params_for_acting_on_existing_transaction!: original_transaction: #{original_transaction.inspect}; new_request_body: #{new_request_body.inspect}")
    end


    def self.validate_charge_object! (charge_params)
      begin
        return true if (self.set_params_for_code_drawdown!(charge_params) if self.has_valid_code?(charge_params)) ||
            (self.set_params_for_card_id_drawdown!(charge_params) if (self.has_valid_card_id?(charge_params) || self.has_valid_contact_id?(charge_params) || self.has_valid_shopper_id?(charge_params)))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid charge_params: #{charge_params.inspect}")
    end

    def self.validate_transaction_response! (transaction_response)
      begin
        return true if (transaction_response.is_a? Hash) &&
            self.has_valid_transaction_id?(transaction_response) &&
            self.has_valid_card_id?(transaction_response)
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid transaction_response: #{transaction_response.inspect}")
    end

    def self.validate_fund_object! (fund_params)
      begin
        return true if (self.set_params_for_card_id_fund!(fund_params) if (self.has_valid_card_id?(fund_params) ||
            self.has_valid_contact_id?(fund_params) || self.has_valid_shopper_id?(fund_params)))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid fund_params: #{fund_params.inspect}")
    end

    def self.validate_ping_response! (ping_response)
      begin
        return true if ((ping_response.is_a? Hash) &&
            (ping_response['user'].is_a? Hash) &&
            !ping_response['user'].empty? &&
            self.validate_username!(ping_response['user']['username']))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid ping_response: #{ping_response.inspect}")
    end


    def self.validate_card_id! (card_id)
      return true if ((card_id.is_a? String) && ((/\A[A-Z0-9\-]+\z/i =~ card_id).is_a? Integer))
      raise Lightrail::LightrailArgumentError.new("Invalid card_id: #{card_id.inspect}")
    end

    def self.validate_code! (code)
      return true if ((code.is_a? String) && ((/\A[A-Z0-9\-]+\z/i =~ code).is_a? Integer))
      raise Lightrail::LightrailArgumentError.new("Invalid code: #{code.inspect}")
    end

    def self.validate_contact_id! (contact_id)
      return true if ((contact_id.is_a? String) && ((/\A[A-Z0-9\-]+\z/i =~ contact_id).is_a? Integer))
      raise Lightrail::LightrailArgumentError.new("Invalid contact_id: #{contact_id.inspect}")
    end

    def self.validate_shopper_id! (shopper_id)
      return true if ((shopper_id.is_a? String) && ((/\A[A-Z0-9\-]+\z/i =~ shopper_id).is_a? Integer))
      raise Lightrail::LightrailArgumentError.new("Invalid shopper_id: #{shopper_id.inspect}")
    end

    def self.validate_transaction_id! (transaction_id)
      return true if ((transaction_id.is_a? String) && !transaction_id.empty?)
      raise Lightrail::LightrailArgumentError.new("Invalid transaction_id: #{transaction_id.inspect}")
    end

    def self.validate_amount! (amount)
      return true if (amount.is_a? Integer)
      raise Lightrail::LightrailArgumentError.new("Invalid amount: #{amount.inspect}")
    end

    def self.validate_currency! (currency)
      return true if (/\A[A-Z]{3}\z/ === currency)
      raise Lightrail::LightrailArgumentError.new("Invalid currency: #{currency.inspect}")
    end

    def self.validate_username!(username)
      return true if ((username.is_a? String) && !username.empty?)
      raise Lightrail::LightrailArgumentError.new("Invalid username: #{username.inspect}")
    end

    private

    def self.set_code!(destination_params, source_params)
      destination_params[:code] ||= self.has_valid_code?(source_params) ? self.get_code(source_params) : nil
    end

    def self.set_cardId!(destination_params, source_params)
      destination_params[:cardId] ||= self.has_valid_card_id?(source_params) ? self.get_card_id(source_params) : nil
    end

    def self.set_transactionId!(destination_params, source_params)
      destination_params[:transactionId] = self.has_valid_transaction_id?(source_params) ? self.get_transaction_id(source_params) : nil
    end

    def self.get_or_set_userSuppliedId!(charge_params)
      charge_params[:userSuppliedId] ||= self.get_or_create_user_supplied_id(charge_params)
    end


    def self.has_valid_code?(charge_params)
      code = (charge_params.respond_to? :keys) ? self.get_code(charge_params) : false
      code && self.validate_code!(code)
    end

    def self.has_valid_card_id?(charge_params)
      cardId = (charge_params.respond_to? :keys) ? self.get_card_id(charge_params) : false
      cardId && self.validate_card_id!(cardId)
    end

    def self.has_valid_contact_id?(charge_params)
      contactId = (charge_params.respond_to? :keys) ? self.get_contact_id(charge_params) : false
      contactId && self.validate_contact_id!(contactId)
    end

    def self.has_valid_shopper_id?(charge_params)
      shopperId = (charge_params.respond_to? :keys) ? self.get_shopper_id(charge_params) : false
      shopperId && self.validate_shopper_id!(shopperId)
    end

    def self.has_valid_user_supplied_id?(charge_params)
      userSuppliedId = (charge_params.respond_to? :keys) ? self.get_user_supplied_id(charge_params) : false
      userSuppliedId && self.validate_shopper_id!(userSuppliedId) # A contact's userSuppliedId is the same as their shopperId
    end

    def self.has_valid_transaction_id?(charge_params)
      transactionId = (charge_params.respond_to? :keys) ? self.get_transaction_id(charge_params) : false
      transactionId && self.validate_transaction_id!(transactionId)
    end


    def self.get_card_id(charge_params)
      card_id_key = (charge_params.keys & Lightrail::Constants::LIGHTRAIL_CARD_ID_KEYS).first
      charge_params[card_id_key]
    end

    def self.get_code(charge_params)
      code_key = (charge_params.keys & Lightrail::Constants::LIGHTRAIL_CODE_KEYS).first
      charge_params[code_key]
    end

    def self.get_contact_id(charge_params)
      contact_id_key = (charge_params.keys & Lightrail::Constants::LIGHTRAIL_CONTACT_ID_KEYS).first
      charge_params[contact_id_key]
    end

    def self.get_shopper_id(charge_params)
      shopper_id_key = (charge_params.keys & Lightrail::Constants::LIGHTRAIL_SHOPPER_ID_KEYS).first
      charge_params[shopper_id_key]
    end

    def self.get_transaction_id(charge_params)
      transaction_id_key = (charge_params.keys & Lightrail::Constants::LIGHTRAIL_TRANSACTION_ID_KEYS).first
      charge_params[transaction_id_key]
    end

    def self.get_code_or_card_id_key(charge_params)
      (charge_params.keys & Lightrail::Constants::LIGHTRAIL_PAYMENT_METHODS).first
    end

    def self.get_user_supplied_id(charge_params)
      user_supplied_id_key = (charge_params.keys & Lightrail::Constants::LIGHTRAIL_USER_SUPPLIED_ID_KEYS).first
      charge_params[user_supplied_id_key]
    end

    def self.get_or_create_user_supplied_id(charge_params)
      user_supplied_id_key = (charge_params.keys & Lightrail::Constants::LIGHTRAIL_USER_SUPPLIED_ID_KEYS).first
      charge_params[user_supplied_id_key] || SecureRandom::uuid
    end

    def self.get_or_create_user_supplied_id_with_action_suffix(charge_params, new_user_supplied_id_base, action_suffix)
      user_supplied_id_key = (charge_params.keys & Lightrail::Constants::LIGHTRAIL_USER_SUPPLIED_ID_KEYS).first
      charge_params[user_supplied_id_key] || "#{new_user_supplied_id_base}-#{action_suffix}"
    end

  end
end