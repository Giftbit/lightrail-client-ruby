module Lightrail
  class Currencies
    def self.create(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/currencies", params)
    end

    def self.get(code)
      Lightrail::Validators.validate_id(code)
      Lightrail::Connection.get("#{Lightrail.api_base}/currencies/#{CGI::escape(code)}")
    end

    def self.list(query_params = {})
      Lightrail::Connection.get("#{Lightrail.api_base}/currencies", query_params)
    end

    def self.update(code, params)
      Lightrail::Validators.validate_id(code)
      Lightrail::Connection.patch("#{Lightrail.api_base}/currencies/#{CGI::escape(code)}", params)
    end

    def self.delete(code)
      Lightrail::Validators.validate_id(code)
      Lightrail::Connection.delete("#{Lightrail.api_base}/currencies/#{CGI::escape(code)}")
    end
  end
end