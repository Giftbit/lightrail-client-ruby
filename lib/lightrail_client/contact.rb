module Lightrail
  class Contact < Lightrail::LightrailObject

    def self.charge(charge_params)
      params_with_account_card_id = self.replace_contact_id_with_card_id(charge_params)
      Lightrail::Card.charge(params_with_account_card_id)
    end

    private

    def self.get_account_card_id_by_contact_id(contact_id, currency)
      card = Lightrail::Connection.get_account_card_by_contact_id_and_currency(contact_id, currency)

      if (!card.nil? && !card.empty? && card['cardId'])
        return card['cardId']
      else
        raise Lightrail::CouldNotFindObjectError.new("Could not find a card for contact_id #{contact_id}")
      end
    end

    def self.replace_contact_id_with_card_id(charge_params)
      contact_id = self.get_contact_id_from_id_or_shopper_id(charge_params)
      account_card_id = self.get_account_card_id_by_contact_id(contact_id, charge_params[:currency])

      params_with_card_id = charge_params.clone
      params_with_card_id[:card_id] = account_card_id
      params_with_card_id.delete(:contact_id)
      params_with_card_id.delete(:shopper_id)
      params_with_card_id
    end


    def self.get_contact_id_from_id_or_shopper_id(charge_params)
      if Lightrail::Validator.has_valid_contact_id?(charge_params)
        return Lightrail::Validator.get_contact_id(charge_params)
      end

      if Lightrail::Validator.has_valid_shopper_id?(charge_params)
        shopper_id = Lightrail::Validator.get_shopper_id(charge_params)
        contact = Lightrail::Connection.get_contact_by_shopper_id(shopper_id)
        if (!contact.nil? && !contact.empty? && contact['contactId'])
          return contact['contactId']
        else
          raise Lightrail::CouldNotFindObjectError.new("Could not find a contact for shopper_id #{shopper_id}")
        end
      end

      raise Lightrail::LightrailArgumentError.new("Missing required parameter 'contact_id' or 'shopper_id': #{charge_params.inspect}")
    end

  end
end
