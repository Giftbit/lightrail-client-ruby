module Lightrail
  class ShopperTokenFactory
    def self.generate (contactId, options=nil)
      raise Lightrail::BadParameterError.new("Lightrail::api_key is not set") unless Lightrail::api_key
      raise Lightrail::BadParameterError.new("Lightrail::shared_secret is not set") unless Lightrail::shared_secret

      raise Lightrail::BadParameterError.new("Must provide a contactId to generate a shopper token") unless contactId

      g = {}

      validity_in_seconds = 43200
      metadata = nil
      if !options
        # no-op
      elsif options.is_a?(Numeric)
        # support for legacy code when options was validity_in_seconds
        validity_in_seconds = options
      elsif options.is_a?(Hash)
        if options.has_key?(:validity_in_seconds)
          validity_in_seconds = options[:validity_in_seconds]
        end
        if options.has_key?(:metadata)
          metadata = options[:metadata]
        end
      end

      if validity_in_seconds <= 0
        raise Lightrail::LightrailArgumentError.new("validity_in_seconds must be > 0")
      end

      payload = Lightrail::api_key.split('.')
      payload = JSON.parse(Base64.decode64(payload[1]))

      g['gui'] = payload['g']['gui']
      g['gmi'] = payload['g']['gmi']
      g['coi'] = contactId
      g['tmi'] = payload['g']['tmi']

      iat = Time.now.to_i
      payload = {
          g: g,
          iat: iat,
          exp: iat + validity_in_seconds,
          iss: "MERCHANT"
      }

      if metadata
        payload["metadata"] = metadata
      end

      JWT.encode(payload, Lightrail::shared_secret, 'HS256')
    end
  end
end
