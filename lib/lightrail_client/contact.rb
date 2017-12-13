module Lightrail
  class Contact < Lightrail::LightrailObject

    def self.create(create_params)
      params_with_user_supplied_id = self.set_user_supplied_id_for_contact_create(create_params)
      params_with_name_if_present = self.set_name_if_present(params_with_user_supplied_id)
      response = Lightrail::Connection.send :make_post_request_and_parse_response, "contacts", params_with_name_if_present
      response['contact']
    end

    def self.retrieve_by_shopper_id(shopper_id)
      response = Lightrail::Connection.send :make_get_request_and_parse_response, "contacts?userSuppliedId=#{CGI::escape(shopper_id)}"
      response['contacts'][0]
    end

    def self.retrieve_by_contact_id(contact_id)
      response = Lightrail::Connection.send :make_get_request_and_parse_response, "contacts/#{CGI::escape(contact_id)}"
      response['contact']
    end

    def self.create_account(account_params)
      validated_params = Lightrail::Validator.set_params_for_account_create!(account_params)
      response = Lightrail::Connection.send :make_post_request_and_parse_response, "cards", validated_params
      response['card']
    end

    def self.charge_account(charge_params)
      params_with_account_card_id = self.replace_contact_id_or_shopper_id_with_card_id(charge_params)
      Lightrail::Card.charge(params_with_account_card_id)
    end

    def self.simulate_account_charge(charge_params)
      params_with_account_card_id = self.replace_contact_id_or_shopper_id_with_card_id(charge_params)
      Lightrail::Card.simulate_charge(params_with_account_card_id)
    end

    def self.fund_account(fund_params)
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
      contact_id = self.get_contact_id_from_id_or_shopper_id(transaction_params)

      if contact_id
        account_card_id = self.get_account_card_id_by_contact_id(contact_id, transaction_params[:currency])
      elsif !Lightrail::Validator.has_valid_card_id?(transaction_params)
        raise Lightrail::LightrailArgumentError.new("Method replace_contact_id_or_shopper_id_with_card_id could not find contact - no contact_id or shopper_id in transaction_params: #{transaction_params.inspect}")
      end

      params_with_card_id = transaction_params.clone
      params_with_card_id[:card_id] = account_card_id if account_card_id
      params_with_card_id.delete(:contact_id)
      params_with_card_id.delete(:shopper_id)
      params_with_card_id
    end

    def self.get_contact_id_from_shopper_id(shopper_id)
      contact = self.retrieve_by_shopper_id(shopper_id)
      contact['contactId']
    end

    def self.set_user_supplied_id_for_contact_create(create_params)
      params_with_user_supplied_id = create_params.clone
      shopper_id = Lightrail::Validator.get_shopper_id(create_params) || nil
      user_supplied_id = Lightrail::Validator.get_user_supplied_id(create_params) || nil

      if !(shopper_id || user_supplied_id)
        raise Lightrail::LightrailArgumentError.new("Must provide one of shopper_id or user_supplied_id to create new Contact")
      elsif (shopper_id && user_supplied_id)
        raise Lightrail::LightrailArgumentError.new("Must provide only one of shopper_id or user_supplied_id to create new Contact")
      end

      if shopper_id
        params_with_user_supplied_id[:userSuppliedId] ||= shopper_id
      elsif user_supplied_id
        params_with_user_supplied_id[:userSuppliedId] ||= user_supplied_id
      end

      params_with_user_supplied_id
    end

    def self.set_account_card_type(create_account_params)
      if (create_account_params['cardType'] && create_account_params['cardType'] != 'ACCOUNT_CARD') ||
          (create_account_params[:cardType] && create_account_params[:cardType] != 'ACCOUNT_CARD')
        raise Lightrail::LightrailArgumentError.new("Cannot create account card if cardType set to value other than 'ACCOUNT_CARD': #{create_account_params.inspect}")
      end
      create_account_params[:cardType] = 'ACCOUNT_CARD'
    end

    def self.set_name_if_present(create_params)
      params_with_name = create_params.clone
      params_with_name[:firstName] ||= params_with_name[:first_name]
      params_with_name[:lastName] ||= params_with_name[:last_name]
      params_with_name
    end

    def self.get_account_card_id_by_contact_id(contact_id, currency)
      card = self.get_account_card_by_contact_id_and_currency(contact_id, currency)

      if (!card.nil? && !card.empty? && card['cardId'])
        return card['cardId']
      else
        return nil
      end
    end

    def self.get_contact_id_from_id_or_shopper_id(charge_params)
      if Lightrail::Validator.has_valid_contact_id?(charge_params)
        return Lightrail::Validator.get_contact_id(charge_params)
      end

      if Lightrail::Validator.has_valid_shopper_id?(charge_params)
        shopper_id = Lightrail::Validator.get_shopper_id(charge_params)
        contact = self.get_by_shopper_id(shopper_id)
        if (!contact.nil? && !contact.empty? && contact['contactId'])
          return contact['contactId']
        else
          return nil
        end
      end

      return nil
    end

    def self.get_account_card_by_contact_id_and_currency(contact_id, currency)
      response = Lightrail::Connection.make_get_request_and_parse_response("cards?contactId=#{contact_id}&cardType=ACCOUNT_CARD&currency=#{currency}")
      response['cards'][0]
    end

    def self.get_by_id(contact_id)
      response = Lightrail::Connection.make_get_request_and_parse_response("contacts/#{contact_id}")
      response['contact']
    end

    def self.get_by_shopper_id(shopper_id)
      response = Lightrail::Connection.make_get_request_and_parse_response("contacts?userSuppliedId=#{shopper_id}")
      response['contacts'][0]
    end
  end
end
