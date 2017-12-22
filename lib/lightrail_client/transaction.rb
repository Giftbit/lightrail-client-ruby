module Lightrail
  class Transaction < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour, :metadata, :parentTransactionId

    def self.charge_code(transaction_params, simulate)
      transaction_type = transaction_params[:pending] ? :code_pending : :code_drawdown
      self.create(transaction_params, transaction_type, simulate)
    end

    def self.charge_card(transaction_params, simulate)
      transaction_type = transaction_params[:pending] ? :card_id_pending : :card_id_drawdown
      self.create(transaction_params, transaction_type, simulate)
    end

    def self.fund_card(transaction_params)
      self.create(transaction_params, :card_id_fund, false)
    end


    def self.refund (original_transaction_info, new_request_body={})
      handle_transaction(original_transaction_info, 'refund', new_request_body)
    end

    def self.void (original_transaction_info, new_request_body={})
      handle_transaction(original_transaction_info, 'void', new_request_body)
    end

    def self.capture (original_transaction_info, new_request_body={})
      handle_transaction(original_transaction_info, 'capture', new_request_body)
    end

    private

    # def self.simulate(transaction_params, transaction_type)
    #   transaction_params_for_lightrail = Lightrail::Validator.send("set_params_for_#{transaction_type}!", transaction_params)
    #   response = self.post_transaction(transaction_params_for_lightrail, true)
    # end

    def self.create(transaction_params, transaction_type, simulate)
      transaction_params_for_lightrail = Lightrail::Validator.send("set_params_for_#{transaction_type}!", transaction_params)
      response = self.post_transaction(transaction_params_for_lightrail, simulate)
    end

    def self.handle_transaction (original_transaction_info, action, new_request_body={})
      transaction_params_for_lightrail = Lightrail::Validator.set_params_for_acting_on_existing_transaction!(original_transaction_info, new_request_body)
      response = self.act_on_transaction(transaction_params_for_lightrail, action)
    end

    def self.post_transaction(transaction_params, simulate)
      dry_run = simulate ? '/dryRun' : ''
      response = {}
      if (transaction_params[:code])
        code = transaction_params.delete(:code)
        response = Lightrail::Connection.send :make_post_request_and_parse_response, "codes/#{CGI::escape(code)}/transactions#{dry_run}", transaction_params
      elsif (transaction_params[:cardId])
        card_id = transaction_params.delete(:cardId)
        response = Lightrail::Connection.send :make_post_request_and_parse_response, "cards/#{CGI::escape(card_id)}/transactions#{dry_run}", transaction_params
      else
        raise Lightrail::LightrailArgumentError.new("Lightrail code or cardId required to post a transaction: #{transaction_params.inspect}")
      end
      response['transaction']
    end

    def self.act_on_transaction(transaction_params, action)
      response = {}
      if (transaction_params[:cardId])
        card_id = transaction_params.delete(:cardId)
        transaction_id = transaction_params.delete(:transactionId)
        response = Lightrail::Connection.send :make_post_request_and_parse_response, "cards/#{CGI::escape(card_id)}/transactions/#{CGI::escape(transaction_id)}/#{action}", transaction_params
      else
        raise Lightrail::LightrailArgumentError.new("Lightrail cardId required to act on an existing transaction: #{transaction_params.inspect}")
      end
      response['transaction']
    end

  end
end
