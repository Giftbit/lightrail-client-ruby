module Lightrail
  class TokenFactory
    def self.generate (contact, validity_in_seconds=nil)
      raise Lightrail::BadParameterError.new("Lightrail::api_key is not set") unless Lightrail::api_key
      raise Lightrail::BadParameterError.new("Lightrail::shared_secret is not set") unless Lightrail::shared_secret

      raise Lightrail::BadParameterError.new("Must provide a contact with one of shopper_id, contact_id or user_supplied_id to generate a shopper token") unless (Lightrail::Validator.has_valid_shopper_id?(contact) ||
          Lightrail::Validator.has_valid_contact_id?(contact) ||
          Lightrail::Validator.has_valid_user_supplied_id?(contact))

      g = {}
      if (Lightrail::Validator.has_valid_shopper_id?(contact))
        g['shi'] = Lightrail::Validator.get_shopper_id(contact)
      elsif (Lightrail::Validator.has_valid_contact_id?(contact))
        g['coi'] = Lightrail::Validator.get_contact_id(contact)
      elsif (Lightrail::Validator.has_valid_user_supplied_id?(contact))
        g['cui'] = Lightrail::Validator.get_user_supplied_id(contact)
      end


      payload = Lightrail::api_key.split('.')
      payload = JSON.parse(Base64.decode64(payload[1]))

      g['gui'] = payload['g']['gui']
      g['gmi'] = payload['g']['gmi']

      iat = Time.now.to_i
      payload = {
          g: g,
          iat: iat,
          iss: "MERCHANT"
      }

      if validity_in_seconds
        payload['exp'] = iat + validity_in_seconds
      end

      token = [
          {'data' => payload},
          {'alg' => 'HS256'}
      ]

      JWT.encode(token, Lightrail::shared_secret, 'HS256')
    end
  end
end