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

    private

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

    def self.set_name_if_present(create_params)
      params_with_name = create_params.clone
      params_with_name[:firstName] ||= params_with_name[:first_name]
      params_with_name[:lastName] ||= params_with_name[:last_name]
      params_with_name
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

    def self.get_by_id(contact_id)
      response = Lightrail::Connection.make_get_request_and_parse_response("contacts/#{CGI::escape(contact_id)}")
      response['contact']
    end

    def self.get_by_shopper_id(shopper_id)
      response = Lightrail::Connection.make_get_request_and_parse_response("contacts?userSuppliedId=#{CGI::escape(shopper_id)}")
      response['contacts'][0]
    end
  end
end
