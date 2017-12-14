module Lightrail
  class Account < Lightrail::LightrailObject
    def self.create(account_params)
      validated_params = Lightrail::Validator.set_params_for_account_create!(account_params)
      response = Lightrail::Connection.send :make_post_request_and_parse_response, "cards", validated_params
      response['card']
    end

    def self.retrieve_by_shopper_id_and_currency(shopper_id, currency)
      Lightrail::Validator.validate_shopper_id!(shopper_id)
      Lightrail::Validator.validate_currency!(currency)
      contact_id = Lightrail::Contact.retrieve_by_shopper_id(shopper_id)['contactId']
      self.retrieve_by_contact_id_and_currency(contact_id, currency)
    end

    def self.retrieve_by_contact_id_and_currency(contact_id, currency)
      Lightrail::Validator.validate_contact_id!(contact_id)
      Lightrail::Validator.validate_currency!(currency)
      response = Lightrail::Connection.send :make_get_request_and_parse_response, "cards?cardType=ACCOUNT_CARD&contactId=#{CGI::escape(contact_id)}&currency=#{CGI::escape(currency)}"
      response['card']
    end

    def self.charge(charge_params)
      params_with_account_card_id = self.replace_contact_id_or_shopper_id_with_card_id(charge_params)
      Lightrail::Card.charge(params_with_account_card_id)
    end

    def self.simulate_charge(charge_params)
      params_with_account_card_id = self.replace_contact_id_or_shopper_id_with_card_id(charge_params)
      Lightrail::Card.simulate_charge(params_with_account_card_id)
    end

    def self.fund(fund_params)
      params_with_account_card_id = self.replace_contact_id_or_shopper_id_with_card_id(fund_params)
      Lightrail::Card.fund(params_with_account_card_id)
    end

    def self.get_account_details(account_details_params)
      params_with_account_card_id = self.replace_contact_id_or_shopper_id_with_card_id(account_details_params)
      Lightrail::Card.get_details(params_with_account_card_id[:card_id])
    end

    def self.get_maximum_account_value(max_account_value_params)
      params_with_account_card_id = self.replace_contact_id_or_shopper_id_with_card_id(max_account_value_params)
      Lightrail::Card.get_maximum_value(params_with_account_card_id[:card_id])
    end


    private

    def self.replace_contact_id_or_shopper_id_with_card_id(transaction_params)
      contact_id = Lightrail::Contact.get_contact_id_from_id_or_shopper_id(transaction_params)

      if contact_id
        account_card_id = self.get_account_card_by_contact_id_and_currency(contact_id, transaction_params[:currency])['cardId']
      elsif !Lightrail::Validator.has_valid_card_id?(transaction_params)
        raise Lightrail::LightrailArgumentError.new("Method replace_contact_id_or_shopper_id_with_card_id could not find contact - no contact_id or shopper_id in transaction_params: #{transaction_params.inspect}")
      end

      params_with_card_id = transaction_params.clone
      params_with_card_id[:card_id] = account_card_id if account_card_id
      params_with_card_id.delete(:contact_id)
      params_with_card_id.delete(:shopper_id)
      params_with_card_id
    end

    # def self.get_account_card_id_by_contact_id(contact_id, currency)
    #   card = self.get_account_card_by_contact_id_and_currency(contact_id, currency)
    #
    #   if (!card.nil? && !card.empty? && card['cardId'])
    #     return card['cardId']
    #   else
    #     return nil
    #   end
    # end

    def self.get_account_card_by_contact_id_and_currency(contact_id, currency)
      response = Lightrail::Connection.make_get_request_and_parse_response("cards?contactId=#{contact_id}&cardType=ACCOUNT_CARD&currency=#{currency}")
      response['cards'][0]
    end

    def self.set_account_card_type(create_account_params)
      if (create_account_params['cardType'] && create_account_params['cardType'] != 'ACCOUNT_CARD') ||
          (create_account_params[:cardType] && create_account_params[:cardType] != 'ACCOUNT_CARD')
        raise Lightrail::LightrailArgumentError.new("Cannot create account card if cardType set to value other than 'ACCOUNT_CARD': #{create_account_params.inspect}")
      end
      create_account_params[:cardType] = 'ACCOUNT_CARD'
    end

  end
end