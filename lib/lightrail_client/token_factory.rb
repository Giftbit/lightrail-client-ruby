module Lightrail
  class TokenFactory
    def self.generate (shopper_id, validity_in_seconds=nil)
      raise Lightrail::BadParameterError.new("Lightrail::api_key is not set") unless Lightrail::api_key
      raise Lightrail::BadParameterError.new("Lightrail::client_secret is not set") unless Lightrail::client_secret

      payload = Lightrail::api_key.split('.')
      payload = JSON.parse(Base64.decode64(payload[1]))
      uid = payload['g']['gui']
      g_claim = {
          gui: uid
      }

      issued_at = Time.now.to_i

      payload = {
          shopperId: shopper_id,
          iat: issued_at,
          g: g_claim
      }

      if validity_in_seconds
        expiry_time = issued_at + validity_in_seconds
        payload[:exp] = expiry_time
      end

      token = [
          {'data' => payload},
          {'alg' => 'HS256'}
      ]

      JWT.encode(token, Lightrail::client_secret, 'HS256')
    end
  end
end