module Lightrail
  class Account < Lightrail::LightrailObject
    def self.create(account_params)
      validated_params = Lightrail::Validator.set_params_for_account_create!(account_params)

      # Make sure contact exists first
      contact_id = Lightrail::Validator.get_contact_id(account_params)
      shopper_id = Lightrail::Validator.get_shopper_id(account_params)

      if contact_id
        contact = Lightrail::Contact.retrieve_by_contact_id(contact_id)
        if shopper_id && (contact['userSuppliedId'] != shopper_id)
          raise Lightrail::LightrailArgumentError.new("Account creation error: you've specified both a contactId and a shopperId for this account, but the contact with that contactId has a different shopperId.")
        end

      elsif shopper_id
        contact = Lightrail::Contact.retrieve_or_create_by_shopper_id(shopper_id)
      end

      if !contact
        raise Lightrail::LightrailArgumentError.new("Account creation error: could not get or create the specified contact. Params: #{account_params}")
      end

      # If the contact already has an account in that currency, return it
      account_card = Lightrail::Account.retrieve({contact_id: contact['contactId'], currency: account_params[:currency]})
      return account_card['cardId'] if account_card

      params_with_contact_id = validated_params.clone
      params_with_contact_id[:contactId] = contact['contactId']
      response = Lightrail::Connection.send :make_post_request_and_parse_response, "cards", params_with_contact_id
      response['card']
    end

    def self.retrieve(account_retrieval_params)
      new_params = account_retrieval_params.clone
      currency = new_params[:currency] || new_params['currency']
      Lightrail::Validator.validate_currency!(currency)
      Lightrail::Validator.set_contactId_from_contact_or_shopper_id!(new_params, new_params)
      contact_id = new_params[:contactId]
      response = Lightrail::Connection.send :make_get_request_and_parse_response, "cards?cardType=ACCOUNT_CARD&contactId=#{CGI::escape(contact_id)}&currency=#{CGI::escape(currency)}"
      response['cards'][0]
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
        account_card_id = self.retrieve({contact_id: contact_id, currency: transaction_params[:currency]})['cardId']
      elsif !Lightrail::Validator.has_valid_card_id?(transaction_params)
        raise Lightrail::LightrailArgumentError.new("Method replace_contact_id_or_shopper_id_with_card_id could not find contact - no contact_id or shopper_id in transaction_params: #{transaction_params.inspect}")
      end

      params_with_card_id = transaction_params.clone
      params_with_card_id[:card_id] = account_card_id if account_card_id
      params_with_card_id.delete(:contact_id)
      params_with_card_id.delete(:shopper_id)
      params_with_card_id
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