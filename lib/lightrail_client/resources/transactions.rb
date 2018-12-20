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

    def self.reverse(transaction_id, params)
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/#{CGI::escape(transaction_id)}/reverse", params)
    end

    def self.capture_pending(transaction_id, params)
      Lightrail::Validators.validate_id(transaction_id, "transaction_id")
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/#{CGI::escape(transaction_id)}/reverse", params)
    end

    def self.void_pending(transaction_id, params)
      Lightrail::Validators.validate_id(pending_id, "pending_id")
      Lightrail::Connection.post("#{Lightrail.api_base}/transactions/#{CGI::escape(transaction_id)}/reverse", params)
    end

    def self.get(id)
      Lightrail::Validators.validate_id(id)
      Lightrail::Connection.get("#{Lightrail.api_base}/transactions/#{CGI::escape(id)}")
    end

    def self.list(query_params)
      Lightrail::Connection.get("#{Lightrail.api_base}/transactions", query_params)
    end
  end
end