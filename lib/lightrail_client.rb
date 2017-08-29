require "faraday"
require "openssl"
require "json"
require "securerandom"

require "lightrail_client/version"

module Lightrail
  class << self
    attr_accessor :api_base, :api_key
  end
  @api_base = 'https://api.lightrail.com/v1'
end
