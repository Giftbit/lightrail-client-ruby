module Lightrail
  class Transactions
    def self.checkout(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/checkout", params)
    end

    def self.debit(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/debit", params)
    end

    def self.credit(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/credit", params)
    end

    def self.transfer(params)
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/transfer", params)
    end

    def self.reverse(id, params)
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/#{CGI::escape(id)}/reverse", params)
    end

    def self.capture_pending(id, params)
      Lightrail::Validators.validate_id(id, "transaction_id")
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/#{CGI::escape(id)}/capture", params)
    end

    def self.void_pending(id, params)
      Lightrail::Validators.validate_id(id, "pending_id")
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/#{CGI::escape(id)}/void", params)
    end

    def self.get(id)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.get("#{Lightrail.api_base}/transactions/#{CGI::escape(id)}")
    end

    def self.list(query_params)
      Lightrail::Connection.get("#{Lightrail.api_base}/transactions", query_params)
    end

    def self.get_transaction_chain(id)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.get("#{Lightrail.api_base}/transactions/#{CGI::escape(id)}/chain")
    end
  end
end