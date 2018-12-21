require "faraday"
require "openssl"
require "json"
require "securerandom"
require "jwt"
require "base64"

require "lightrail_client/version"

require "lightrail_client/errors"
require "lightrail_client/lightrail_response_objects"
require "lightrail_client/shopper_token_factory"
require "lightrail_client/connection"
require "lightrail_client/validators"

require "lightrail_client/resources/contacts"
require "lightrail_client/resources/currencies"
require "lightrail_client/resources/programs"
require "lightrail_client/resources/transactions"
require "lightrail_client/resources/values"

module Lightrail
  class << self
    attr_accessor :api_base, :api_key, :shared_secret
  end
  @api_base = 'https://api.lightrail.com/v2'
end
