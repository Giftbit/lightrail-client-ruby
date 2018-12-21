module Lightrail
  class Values
    def self.create(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/values", params)
    end

    def self.get(id, query_params = {})
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.get("#{Lightrail.api_base}/values/#{CGI::escape(id)}", query_params)
    end

    def self.list(query_params = {})
      Lightrail::Connection.get("#{Lightrail.api_base}/values", query_params)
    end

    def self.update(id, params)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.patch("#{Lightrail.api_base}/values/#{CGI::escape(id)}", params)
    end

    def self.change_code(id, params)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.post("#{Lightrail.api_base}/values/#{CGI::escape(id)}/changeCode", params)
    end

    def self.delete(id)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.delete("#{Lightrail.api_base}/values/#{CGI::escape(id)}")
    end
  end
end