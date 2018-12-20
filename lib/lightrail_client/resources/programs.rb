module Lightrail
  class Programs
    def self.create(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/programs", params)
    end

    def self.get(id)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.get("#{Lightrail.api_base}/programs/#{CGI::escape(id)}")
    end

    def self.list(query_params = {})
      Lightrail::Connection.get("#{Lightrail.api_base}/programs", query_params)
    end

    def self.update(id, params)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.patch("#{Lightrail.api_base}/programs/#{CGI::escape(id)}", params)
    end

    def self.create_issuance(program_id, params)
      Lightrail::Validators.validate_id(program_id, "program_id")
      Lightrail::Connection.post("#{Lightrail.api_base}/programs/#{CGI::escape(program_id)}/issuances", params)
    end

    def self.list_issuances(program_id, query_params = {})
      Lightrail::Validators.validate_id(program_id, "program_id")
      Lightrail::Connection.get("#{Lightrail.api_base}/programs/#{CGI::escape(program_id)}/issuances", query_params)
    end

    def self.get_issuance(program_id, issuance_id)
      Lightrail::Validators.validate_id(program_id, "program_id")
      Lightrail::Validators.validate_id(issuance_id, "issuance_id")
      Lightrail::Connection.get("#{Lightrail.api_base}/programs/#{CGI::escape(program_id)}/issuances/#{CGI::escape(issuance_id)}")
    end

    def self.delete(id)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.delete("#{Lightrail.api_base}/programs/#{CGI::escape(id)}")
    end
  end
end