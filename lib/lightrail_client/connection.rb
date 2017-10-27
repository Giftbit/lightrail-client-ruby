module Lightrail
  class Connection
    def self.connection
      conn = Faraday.new Lightrail.api_base, ssl: {version: :TLSv1_2}
      conn.headers['Content-Type'] = 'application/json; charset=utf-8'
      conn.headers['Authorization'] = "Bearer #{Lightrail.api_key}"
      conn
    end

    def self.ping
      self.make_get_request_and_parse_response('ping')
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