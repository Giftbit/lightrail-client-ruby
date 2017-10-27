module Lightrail
  class Connection
    def self.get_balance_details(by_code_or_card, fullcode_or_card_id)
      response = by_code_or_card == :code ?
          self.get_code_balance(fullcode_or_card_id) :
          self.get_card_id_balance(fullcode_or_card_id)
      response['balance']
    end

    def self.get_contact_by_id(contact_id)
      response = self.send :make_get_request_and_parse_response, "contacts/#{contact_id}"
      response['contact']
    end

    def self.get_contact_by_shopper_id(shopper_id)
      response = self.send :make_get_request_and_parse_response, "contacts?userSuppliedId=#{shopper_id}"
      response['contacts'][0]
    end

    def self.get_account_card_by_contact_id_and_currency(contact_id, currency)
      response = self.send :make_get_request_and_parse_response, "cards?contactId=#{contact_id}&cardType=ACCOUNT_CARD&currency=#{currency}"
      response['cards'][0]
    end

    def self.ping
      self.send :make_get_request_and_parse_response, "ping"
    end

    def self.get_code_balance(code)
      self.send :make_get_request_and_parse_response, "codes/#{code}/balance/details"
    end

    def self.get_card_id_balance(card_id)
      self.send :make_get_request_and_parse_response, "cards/#{card_id}/balance"
    end


    private

    def self.connection
      conn = Faraday.new Lightrail.api_base, ssl: {version: :TLSv1_2}
      conn.headers['Content-Type'] = 'application/json; charset=utf-8'
      conn.headers['Authorization'] = "Bearer #{Lightrail.api_key}"
      conn
    end

    def self.make_post_request_and_parse_response (url, body)
      resp = Lightrail::Connection.connection.post do |req|
        req.url url
        req.body = JSON.generate(body)
      end
      self.handle_response(resp)
    end

    def self.make_get_request_and_parse_response (url)
      resp = Lightrail::Connection.connection.get {|req| req.url url}
      self.handle_response(resp)
    end

    def self.handle_response(response)
      body = JSON.parse(response.body) || {}
      message = body['message'] || ''
      case response.status
        when 200...300
          JSON.parse(response.body)
        when 400
          if (message =~ /insufficient value/i)
            raise Lightrail::InsufficientValueError.new(message, response)
          else
            raise Lightrail::BadParameterError.new(message, response)
          end
        when 401, 403
          raise Lightrail::AuthorizationError.new(message, response)
        when 404
          raise Lightrail::CouldNotFindObjectError.new(message, response)
        when 409
          raise Lightrail::BadParameterError.new(message, response)
        else
          raise LightrailError.new("Server responded with: (#{response.status}) #{message}", response)
      end
    end

  end
end