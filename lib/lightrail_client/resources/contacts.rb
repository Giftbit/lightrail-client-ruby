module Lightrail
  class Contacts
    def self.create(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/contacts", params)
    end

    def self.get(id)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.get("#{Lightrail.api_base}/contacts/#{CGI::escape(id)}")
    end

    def self.list(query_params = {})
      Lightrail::Connection.get("#{Lightrail.api_base}/contacts", query_params)
    end

    def self.update(id, params)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.patch("#{Lightrail.api_base}/contacts/#{CGI::escape(id)}", params)
    end

    def self.attach_value_to_contact(contact_id, params)
      Lightrail::Validators.validate_id(contact_id, "contact_id")
      Lightrail::Connection.post("#{Lightrail.api_base}/contacts/#{CGI::escape(contact_id)}/values/attach", params)
    end

    def self.list_contact_values(contact_id, query_params = {})
      Lightrail::Connection.get("#{Lightrail.api_base}/contacts/#{CGI::escape(contact_id)}/values", query_params)
    end

    def self.delete(id)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.delete("#{Lightrail.api_base}/contacts/#{CGI::escape(id)}")
    end
  end
end