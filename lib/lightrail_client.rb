require "faraday"
require "openssl"
require "json"
require "securerandom"

require "lightrail_client/version"

require "lightrail_client/constants"
require "lightrail_client/errors"
require "lightrail_client/validator"
require "lightrail_client/connection"

require "lightrail_client/lightrail_object"
require "lightrail_client/ping"
require "lightrail_client/transaction"
require "lightrail_client/card"
require "lightrail_client/code"

module Lightrail
  class << self
    attr_accessor :api_base, :api_key
  end
  @api_base = 'https://api.lightrail.com/v1'
end
