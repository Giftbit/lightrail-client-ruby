module Lightrail
  class Constants

    code_keys_sym = [:code, :lightrail_code]
    card_id_keys_sym = [:cardId, :card_id, :lightrail_card_id]
    contact_id_keys_sym = [:contactId, :contact_id, :lightrail_contact_id]
    shopper_id_keys_sym = [:shopperId, :shopper_id, :lightrail_shopper_id]
    user_supplied_id_keys_sym = [:userSuppliedId, :user_supplied_id, :lightrail_user_supplied_id, :idempotency_key]
    transaction_id_keys_sym = [:transactionId, :transaction_id, :lightrail_transaction_id]

    LIGHTRAIL_CODE_KEYS = code_keys_sym + code_keys_sym.map {|code_key| code_key.to_s}
    LIGHTRAIL_CARD_ID_KEYS = card_id_keys_sym + card_id_keys_sym.map {|card_id_key| card_id_key.to_s}
    LIGHTRAIL_CONTACT_ID_KEYS = contact_id_keys_sym + contact_id_keys_sym.map {|contact_id_key| contact_id_key.to_s}
    LIGHTRAIL_SHOPPER_ID_KEYS = shopper_id_keys_sym + shopper_id_keys_sym.map {|shopper_id_key| shopper_id_key.to_s}
    LIGHTRAIL_USER_SUPPLIED_ID_KEYS = user_supplied_id_keys_sym + user_supplied_id_keys_sym.map {|user_supplied_id_key| user_supplied_id_key.to_s}
    LIGHTRAIL_TRANSACTION_ID_KEYS = transaction_id_keys_sym + transaction_id_keys_sym.map {|transaction_id_key| transaction_id_key.to_s}

    LIGHTRAIL_PAYMENT_METHODS = self::LIGHTRAIL_CODE_KEYS + self::LIGHTRAIL_CARD_ID_KEYS + self::LIGHTRAIL_CONTACT_ID_KEYS + self::LIGHTRAIL_SHOPPER_ID_KEYS

    LIGHTRAIL_TRANSACTION_TYPES = [:code_drawdown, :card_id_drawdown, :code_pending, :card_id_pending, :fund_card, :refund, :capture, :void]

  end
end